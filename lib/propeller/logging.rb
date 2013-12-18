module Propeller
  module Logging
    def individual
      @individual ||= Logger.new(Rails.root.join("log/propeller-worker-#{worker_id}.log"))
      @individual.level = Logger::DEBUG
      @individual
    end

    def mutual
      # Use Lumberjack::Logger as it writes faster to the log file. Using
      # Rails::Logger can cause some buffering which results in lag.
      @mutual ||= Lumberjack::Logger.new(Rails.root.join("log/propeller-workers.log"))
      @mutual.level = Lumberjack::Logger::DEBUG
      @mutual
    end

    # Log to both the propeller-worker's file and a mutual log file for all q-workers.
    def debug(message)
      individual.debug("[propeller-worker #{worker_id}] #{message}")
      mutual.debug("[propeller-worker #{worker_id}] #{message}")
    end
  end
end
