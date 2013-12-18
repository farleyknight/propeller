require 'less-rails-bootstrap'

require "propeller/engine"
require "propeller/logging"
require "propeller/config"
require "propeller/worker"
require "propeller/worker_job_methods"

require 'lumberjack'

module Propeller
  def self.config(&block)
    if block_given?
      @config = Config.new
      block.call(@config)
    else
      @config
    end
  end

  class AppWorker
    def initialize(job, worker_job)
      @job        = job
      @worker_job = worker_job
      @options    = worker_job.arguments.with_indifferent_access
    end

    def perform
      # Do something!
    end
  end
end
