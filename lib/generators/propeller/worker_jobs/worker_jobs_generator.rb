module Propeller
  class WorkerJobsGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_worker_jobs_migration
      migration_template "migration.rb", "db/migrate/worker_jobs_create.rb"
    end
  end
end
