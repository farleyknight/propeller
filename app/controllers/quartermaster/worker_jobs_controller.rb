require_dependency "quartermaster/application_controller"

module Quartermaster
  class WorkerJobsController < ApplicationController
    def index
      @recent_jobs = WorkerJob.order("updated_at desc").limit(50)
    end

    def all
      @recent_jobs = WorkerJob.order("updated_at desc").limit(50)
      render text: render_to_string(partial: "quartermaster/worker_jobs/table", locals: {jobs: @recent_jobs})
    end

    def completed
      @recent_jobs = WorkerJob.completed.order("updated_at desc").limit(50)
      render text: render_to_string(partial: "quartermaster/worker_jobs/table", locals: {jobs: @recent_jobs})
    end

    def queued
      @recent_jobs = WorkerJob.queued.order("updated_at desc").limit(50)
      render text: render_to_string(partial: "quartermaster/worker_jobs/table", locals: {jobs: @recent_jobs})
    end

    def failed
      @recent_jobs = WorkerJob.failed.order("updated_at desc").limit(50)
      render text: render_to_string(partial: "quartermaster/worker_jobs/table", locals: {jobs: @recent_jobs})
    end

    def counts
      render json: WorkerJob.group(:status).count.to_a
    end
  end
end
