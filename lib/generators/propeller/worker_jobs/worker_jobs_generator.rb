require 'rails/generators'
require 'rails/generators/active_record'

module Propeller
  class WorkerJobsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    def copy_worker_jobs_migration
      migration_template "migration.rb", "db/migrate/worker_job.rb"
    end

    def generate_model
      copy_file "worker_job.rb", "app/models/worker_job.rb"
    end

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number dirname
    end
  end
end
