module Propeller
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
      individual.debug("[q-worker #{worker_id}] #{message}")
      mutual.debug("[q-worker #{worker_id}] #{message}")
    end
  end
end
