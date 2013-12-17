class WorkerJob < ActiveRecord::Base
  def self.recent_jobs_columns
    {
      # TODO: You should add columns specific to your jobs here.
      "Job type"      => :klass,
      "Status"        => :status
    }
  end
end
