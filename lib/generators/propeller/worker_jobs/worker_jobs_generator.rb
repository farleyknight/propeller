require 'rails/generators/active_record'

module Propeller
  class WorkerJobsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    extend NextMigrationVersion

    source_root File.expand_path('../templates', __FILE__)

    def copy_worker_jobs_migration
      migration_template "migration.rb", "db/migrate/worker_jobs_create.rb"
    end

    def self.next_migration_number dirname
      ActiveRecord::Generators::Base.next_migration_number dirname
    end
  end
end
