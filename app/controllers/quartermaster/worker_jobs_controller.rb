require_dependency "quartermaster/application_controller"

module Quartermaster
  class WorkerJobsController < ApplicationController
    def index
      @recent_jobs = WorkerJob.order("updated_at desc").limit(50)
    end

    def all
      render_table(all_jobs)
    end

    def completed
      render_table(completed_jobs)
    end

    def queued
      render_table(queued_jobs)
    end

    def failed
      render_table(failed_jobs)
    end

    def retired
      render_table(retired_jobs)
    end

    def counts
      render json: WorkerJob.group(:status).count.to_a
    end

    protected
    def worker_job_class
      Quartermaster.config.worker_job_class
    end

    def render_table(jobs)
      render text: render_to_string(partial: "quartermaster/worker_jobs/table", locals: {jobs: jobs})
    end

    def all_jobs
      worker_job_class.order("updated_at desc").limit(50)
    end

    def completed_jobs
      worker_job_class.completed.order("updated_at desc").limit(50)
    end

    def queued_jobs
      worker_job_class.queued.order("updated_at desc").limit(50)
    end

    def failed_jobs
      worker_job_class.failed.order("updated_at desc").limit(50)
    end

    def retired_jobs
      worker_job_class.retired.order("updated_at desc").limit(50)
    end
  end
end
