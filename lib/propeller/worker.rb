module Propeller
  # Propeller::Worker is the main worker that runs all jobs.
  # It's initialized and started inside the `propeller:run`
  # rake task.
  class Worker
    attr_accessor :worker_id
    include Logging

    # Reduce the Propeller::Worker rake task to just one method: this one.
    def self.start!(env)
      raise "Cannot start Propeller::Worker without a WORKER_ID!" if env["WORKER_ID"].blank?

      worker_id = env["WORKER_ID"]
      pid_file  = Rails.root.join("tmp", "pids", "propeller-worker-#{worker_id}.pid")

      File.open(pid_file, 'w') do |f|
        f << Process.pid
      end

      w = Worker.new(worker_id)

      at_exit do
        w.debug("Exiting..")
      end

      w.run!
    end

    # Name the worker for logging
    def initialize(id)
      @worker_id   = id
      @worker_name = "worker-#{id}"
      debug("Starting worker")
    end

    # Access the Propeller.config object as an instance method
    def config
      Propeller.config
    end

    # We continue running jobs until we hit the throttling
    # constraints. If even one of the throttling constraints
    # are hit, we stop running the jobs loop. We start again.
    def run
      debug("Running job loop")
      loop do
        while under_throttling_limits?
          run_one_job!
          sleep(config.polling_interval)
        end
        debug("Waiting for job rate to go under throttling limits")
        # When we reach this point, we've hit the throttling
        # limit and sleep for a period of time before checking
        # the throttling constraints again.
        sleep(config.throttle_interval)
      end
    end

    # Perform the worker loop, but catch any possible errors and print them
    # to the log file.
    def run!
      begin
        run
      rescue => error
        debug(error.message)
        error.backtrace.each do |line|
          debug(line)
        end
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
        sleep(config.idle_period)
      end
    end

    # Check if we're under the throttling limits
    def under_throttling_limits?
      config.throttle_limits.each do |period, total|
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
      config.worker_job_class.throttle_limit(period)
    end

    # Lock the job and return the job's AR object.
    def lock_job!
      config.worker_job_class.unreserved.limit(1).lock(true).first
    end

    # Grab the first unreserved job in the database table, and
    # start a job.
    def reserve_job!
      worker_job = nil
      start      = Time.now

      config.worker_job_class.transaction do
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
        Propeller::Worker::Job.new(self, worker_job)
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
          finish!
        rescue => error
          handle_error(error)
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
