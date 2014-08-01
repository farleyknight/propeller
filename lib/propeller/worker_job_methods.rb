require "propeller/worker_job_methods/instance_methods"
require "propeller/worker_job_methods/class_methods"

module Propeller
  module WorkerJobMethods
    def self.included(base)
      base.class_eval do
        validates_presence_of :status

        has_many :job_failures
        alias :failures :job_failures
      end

      base.send :include, InstanceMethods
      base.send :extend,  ClassMethods
    end
  end
end
