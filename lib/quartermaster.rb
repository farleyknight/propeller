require "quartermaster/engine"
require "quartermaster/logging"
require "quartermaster/config"
require "quartermaster/worker"

require 'lumberjack'

module Quartermaster
  def self.config(&block)
    if block_given?
      @config = Config.new
      block.call(@config)
    else
      @config
    end
  end

  module WorkerJobMethods
    def self.included(base)
      base.class_eval do
        validates_uniqueness_of :service_key, scope: [:datetime, :klass]
        has_many :job_failures
      end
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

    module InstanceMethods
      def start!
        self.started_at = Time.now
        self.status     = "reserved"
        self.save!
      end

      # TODO: Rename columns for beginning_of_* to started_at_beginning_of_*
      def started_at=(other)
        self[:started_at]          = other
        self[:beginning_of_minute] = other.beginning_of_minute
        self[:beginning_of_hour]   = other.beginning_of_hour
        self[:beginning_of_day]    = other.beginning_of_day
      end

      def finish!
        update_attributes({
          ended_at:   Time.now,
          status:     "completed"
        })
      end

      def failed!(error)
        update_attributes(status: "failed")

        Rails.logger.debug("[worker_job] The job is now marked as: #{self.status}")

        failures.create!({
          error_class: error.class.name,
          backtrace:   error.backtrace.join("\n"),
          message:     error.message
        })

        # Retire jobs that fail over and over.
        if failures.where("created_at > ?", 10.minutes.ago).count >= 10
          update_attributes(status: "retired")
        end
      end

      def job_length
        ended_at - started_at
      end

      def datetime=(other)
        self[:datetime]        = other
        if other.is_a? String
          self.scheduled_at      = DateTime.parse(other)
          self.scheduled_at_date = Date.parse(other)
        else
          self.scheduled_at      = other
          self.scheduled_at_date = other.to_date
        end
      end

      def queue!(options)
        create({
          status:            "queued",
          scheduled_at:      options[:datetime],
          scheduled_at_date: options[:datetime]
        }.merge(options))
      end
    end

    # TODO: Rename scheduled_at to scheduled_for
    # TODO: Rename scheduled_at_date to scheduled_for_date

    # Class methods
    module ClassMethods
      # Unreserved is used to select new jobs from the queue.
      # If a job is marked as completed, reserved, or retired,
      # we ignore it and grab the next.
      def unreserved
        where("status != 'completed'")
          .where("status != 'reserved'")
          .where("status != 'retired'")
          .order("scheduled_at_date desc")
      end

      def throttle_limit(period)
        where("started_at between ? and ?", period.ago, Time.now).count
      end

      def completed
        where(status: "completed")
      end

      def queued
        where(status: "queued")
      end

      def failed
        where(status: "failed")
      end

      def reserved
        where(status: "reserved")
      end

      def retired
        where(status: "retired")
      end
    end
  end
end
