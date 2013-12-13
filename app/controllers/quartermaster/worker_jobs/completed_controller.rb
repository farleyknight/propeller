require_dependency "quartermaster/application_controller"

module Quartermaster
  class WorkerJobs::CompletedController < ApplicationController
    def daily
      render json: worker_job_class.daily_report.to_json
    end

    def hourly
      render json: worker_job_class.hourly_report.to_json
    end

    def minutely
      render json: worker_job_class.minutely_report.to_json
    end

    protected
    def worker_job_class
      Quartermaster.config.worker_job_class
    end
  end
end
