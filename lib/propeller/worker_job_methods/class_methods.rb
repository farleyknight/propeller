module Propeller
  module WorkerJobMethods
    # Class methods
    module ClassMethods
      # Unreserved is used to select new jobs from the queue.
      # If a job is marked as completed, reserved, or retired,
      # we ignore it and grab the next.
      def unreserved
        where("status != 'completed'")
          .where("status != 'reserved'")
          .where("status != 'retired'")
          .order("scheduled_for_date desc")
      end

      # Mark the job as queued
      def queue!(options)
        create({
          status:             "queued",
          scheduled_for:      options[:datetime],
          scheduled_for_date: options[:datetime]
        }.merge(options))
      end

      # Check the throttle limit
      def throttle_limit(period)
        where("started_at between ? and ?", period.ago, Time.now).count
      end

      # Job states
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

      # Reports
      def hourly_report
        HourlyReport.new.hourly_report
      end

      class HourlyReport
        def query
          WorkerJob
            .where("started_at_beginning_of_hour > ?", hourly_report.hours.ago.beginning_of_hour)
            .completed.group(:started_at_beginning_of_hour)
            .count
        end

        def report_data
          query_data       = query

          start_hour       = hourly_report.hours.ago.beginning_of_hour
          current_hour     = start_hour
          end_hour         = Time.now.beginning_of_hour
          data             = []

          while current_hour <= end_hour
            data << [current_hour.to_i * 1000, query_data[current_hour]]
            current_hour  += 1.hour
          end

          data
        end

        def hourly_report
          [{
            key:   "Completed Jobs by Hour",
            values: report_data
          }]
        end
      end

      def daily_report
        DailyReport.new.daily_report
      end

      class DailyReport
        def days_ago
          Propeller.config.report_days_ago
        end

        def query
          WorkerJob
            .completed
            .where("started_at_beginning_of_day > ?", days_ago.days.ago)
            .group(:started_at_beginning_of_day)
            .count
        end

        def report_data
          query_data       = query

          start_day        = days_ago.days.ago.to_date
          current_day      = start_day
          end_day          = Date.today
          data             = []

          while current_day <= end_day
            data    << [current_day.to_time.to_i * 1000, query_data[current_day].to_i]
            current_day   += 1
          end

          data
        end

        def daily_report
          [{
            key:    "Completed Jobs by Day",
            values: report_data
          }]
        end
      end

      def minutely_report
        MinutelyReport.new.minutely_report
      end

      class MinutelyReport
        def minutes_ago
          Propeller.config.report_minutes_ago
        end

        def query
          WorkerJob.completed.group(:started_at_beginning_of_minute)
            .where("started_at_beginning_of_minute > ?", minutes_ago.minutes.ago.beginning_of_minute)
            .count
        end

        def report_data
          query_data       = query

          start_minute     = minutes_ago.minutes.ago.beginning_of_minute
          current_minute   = start_minute
          end_minute       = Time.now.beginning_of_minute
          data             = []

          while current_minute <= end_minute
            data    << [current_minute.to_i * 1000, query_data[current_minute]]
            current_minute += 1.minute
          end

          data
        end

        def minutely_report
          [{
            key:   "Completed Jobs by Minute",
            values: report_data
          }]
        end
      end
    end
  end
end
