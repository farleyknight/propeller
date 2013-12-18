require 'rails/generators'
require 'rails/generators/active_record'

module Propeller
  class WorkerJobsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    def copy_worker_jobs_migration
      migration_template "worker_migration.rb", "db/migrate/worker_job.rb"
    end

    def copy_job_failures_migration
      migration_template "failure_migration.rb", "db/migrate/job_failure.rb"
    end

    def generate_worker_job
      copy_file "worker_job.rb", "app/models/worker_job.rb"
    end

    def generate_job_failure
      copy_file "job_failure.rb", "app/models/job_failure.rb"
    end

    def generate_app_worker
      copy_file "app_worker.rb", "app/workers/app_worker.rb"
    end

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number dirname
    end
  end
end
