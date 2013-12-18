module Propeller
  module WorkerJobMethods
    module InstanceMethods
      def start!
        self.started_at = Time.now
        self.status     = "reserved"
        self.save!
      end

      def started_at=(other)
        self[:started_at]                     = other
        self[:started_at_beginning_of_minute] = other.beginning_of_minute
        self[:started_at_beginning_of_hour]   = other.beginning_of_hour
        self[:started_at_beginning_of_day]    = other.beginning_of_day
      end

      def finish!
        update_attributes({
          ended_at:   Time.now,
          status:     "completed"
        })
      end

      # TODO: This should be implemented by the user.
      def too_many_failures?
        failures.where("created_at > ?", 10.minutes.ago).count >= 10
      end

      def failed!(error)
        update_attributes(status: "failed")

        failures.create!({
          error_class: error.class.name,
          backtrace:   error.backtrace.join("\n"),
          message:     error.message
        })

        # Retire jobs that fail over and over.
        if too_many_failures?
          update_attributes(status: "retired")
        end
      end

      # Used to determine the average length of time to finish a job.
      def job_length
        ended_at - started_at
      end

      def datetime=(other)
        self[:datetime]        = other
        if other.is_a? String
          self.scheduled_for      = DateTime.parse(other)
          self.scheduled_for_date = Date.parse(other)
        else
          self.scheduled_for      = other
          self.scheduled_for_date = other.to_date
        end
      end
    end
  end
end
