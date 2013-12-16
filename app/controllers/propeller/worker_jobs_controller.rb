require_dependency "propeller/application_controller"

module Propeller
  class WorkerJobsController < ApplicationController
    def index
      @recent_jobs = all_jobs
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
      render json: worker_job_class.group(:status).count.to_a
    end

    protected
    def worker_job_class
      Propeller.config.worker_job_class
    end

    def render_table(jobs)
      render text: render_to_string(partial: "propeller/worker_jobs/table", locals: {jobs: jobs})
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
