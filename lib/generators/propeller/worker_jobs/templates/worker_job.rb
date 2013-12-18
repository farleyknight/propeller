class WorkerJob < ActiveRecord::Base
  include Propeller::WorkerJobMethods

  class << self
    def recent_jobs_columns
      {
        # TODO: You should add columns specific to your jobs here.
        "Job type"      => :klass,
        "Status"        => :status
      }
    end
  end
end
