require "quartermaster/engine"

module Quartermaster
  module Logging
    def individual
      @individual     ||= Logger.new(Rails.root.join("log/q-worker-#{worker_id}.log"))
      @individual.level = Logger::DEBUG
      @individual
    end

    def mutual
      # Use Lumberjack::Logger as it writes faster to the log file. Using
      # Rails::Logger can cause some buffering which results in lag.
      @mutual     ||= Lumberjack::Logger.new(Rails.root.join("log/q-workers.log"))
      @mutual.level = Lumberjack::Logger::DEBUG
      @mutual
    end

    # Log to both the q-worker's file and a mutual log file for all q-workers.
    def debug(message)
      @individual.debug("[q-worker #{worker_id}] #{message}")
      @mutual.debug("[q-worker #{worker_id}] #{message}")
    end
  end

  class Config
    class << self
      # TODO: Make this configurable by the host Rails application.
      def worker_job_class
        WorkerJob
      end

      # TODO: Make this configurable by the host Rails application.
      def throttle_limits
        {1.minute => 10}
      end

      # TODO: Make this configurable by the host Rails application.
      def polling_interval
        2.seconds
      end

      # TODO: Make this configurable by the host Rails application.
      def throttle_interval
        1.second
      end

      # TODO: Make this configurable by the host Rails application.
      def idle_period
        5.minutes
      end
    end
  end

  # Quartermaster::Worker is the main worker that runs all jobs.
  # It's initialized and started inside the `quartermaster:run`
  # rake task.
  class Worker
    attr_accessor :worker_id
    include Logging

    # Reduce the Quartermaster::Worker rake task to just one method: this one.
    def self.start!(env)
      raise "Cannot start Quartermaster::Worker without a WORKER_ID!" if env["WORKER_ID"].blank?
      raise "Cannot start Quartermaster::Worker without a PIDFILE!"   if env["PIDFILE"].blank?

      if env['PIDFILE']
        File.open(env['PIDFILE'], 'w') do |f|
          f << Process.pid
        end
      end

      w = Worker.new(env["WORKER_ID"])

      at_exit do
        w.debug("Exiting..")
      end

      begin
        w.run
      rescue => error
        w.debug(error.message)
        error.backtrace.each do |line|
          w.debug(line)
        end
      end
    end

    # Name the worker for logging
    def initialize(id)
      @worker_id   = id
      @worker_name = "worker-#{id}"
      debug("Starting worker")
    end

    # We continue running jobs until we hit the throttling
    # constraints. If even one of the throttling constraints
    # are hit, we stop running the jobs loop. We start again.
    def run
      debug("Running job loop")
      loop do
        while under_throttling_limits?
          run_one_job!
          sleep(Config.polling_interval)
        end
        debug("Waiting for job rate to go under throttling limits")
        # When we reach this point, we've hit the throttling
        # limit and sleep for a period of time before checking
        # the throttling constraints again.
        sleep(Config.throttle_interval)
      end
    end

    # Reserve a job. If we catch an error here, show the
    # stacktrace.
    def reserve_one_job!
      begin
        debug("Attemping to lock a new job")
        job = reserve_job!
        return job
      rescue => error
        debug("Couldn't lock a new job. Exiting..")
        debug("Full stack trace below")
        debug(error.message)
        error.backtrace.each do |line|
          debug(line)
        end
        exit(1)
      end
    end

    # Reserve the job and perform it.
    def run_one_job!
      job = reserve_one_job!

      unless job.blank?
        debug("Locked job #{job.worker_job.id}")
        job.perform!
        debug("Unlocked job #{job.worker_job.id}")
      else
        debug("Couldn't find a job to reserve. Idling..")
        sleep(Config.idle_period)
      end
    end

    # Check if we're under the throttling limits
    def under_throttling_limits?
      Config.throttle_limits.each do |period, total|
        count = performed_jobs_count(period)
        debug("#{count} jobs peformed within #{period}")
        if count >= total
          return false
        end
      end

      return true
    end

    # The number of jobs performed is the number of jobs
    # started within a given period
    # Example:
    #
    # performed_jobs_count(1.hour) => # 500
    #
    # So there were 500 jobs performed within the last hour.
    def performed_jobs_count(period)
      Config.worker_job_class.throttle_limit(period)
    end

    # Lock the job and return the job's AR object.
    def lock_job!
      Config.worker_job_class.unreserved.limit(1).lock(true).first
    end

    # Grab the first unreserved job in the database table, and
    # start a job.
    def reserve_job!
      worker_job = nil
      start      = Time.now

      Config.worker_job_class.transaction do
        worker_job = lock_job!
        if worker_job.blank?
          debug("No job to reserve!")
        else
          debug("Reserving job #{worker_job.id}")
          worker_job.start!
          debug("Reserved job #{worker_job.id}")
        end
      end

      unless worker_job.blank?
        debug("Transaction duration: #{Time.now - start} seconds")
        Quartmaster::Worker::Job.new(self, worker_job)
      end
    end

    # Wraps a worker job, so we can perform the job and then mark
    # it as completed, or it fails and we can log that failure.
    class Job
      attr_accessor :worker_job, :queue

      def initialize(queue, worker_job)
        @queue      = queue
        @worker_job = worker_job
      end

      def debug(message)
        @queue.debug(message)
      end

      def perform!
        begin
          run_job!
        rescue => error
          handle_error(error)
        ensure
          finish!
        end
      end

      # klass will be specified by the user
      def run_job!
        # This should be resolved properly by the host Rails app
        klass = @worker_job.klass.constantize
        job   = klass.new(self, @worker_job)
        job.perform
      end

      # These last 3 methods are called in Job#run_job!
      #
      # Mark the job as failed
      def handle_error(error)
        debug("Got failure! #{error.message}")
        @worker_job.failed!(error)
      end

      # Mark the job as finished
      def finish!
        @worker_job.finish!
      end
    end
  end
end
