module Propeller
  class Config
    attr_accessor(
      :worker_job_class_name, :throttle_limits, :polling_interval,
      :throttle_interval,     :idle_period
    )

    def worker_job_class
      worker_job_class_name.constantize
    end

    def worker_job_class_name
      @worker_job_class_name || "WorkerJob"
    end

    def throttle_limits
      @throttle_limits || {1.minute => 10}
    end

    def polling_interval
      @polling_interval || 2.seconds
    end

    def throttle_interval
      @throttle_interval || 1.second
    end

    def idle_period
      @idle_period || 5.minutes
    end
  end
end
