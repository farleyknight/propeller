require_dependency "quartermaster/application_controller"

module Quartermaster
  class WorkerJobs::CompletedController < ApplicationController
    def daily
      render json: WorkerJob.daily_report.to_json
    end

    def weekly
      render json: WorkerJob.hourly_report.to_json
    end

    def minutely
      render json: WorkerJob.minutely_report.to_json
    end
  end
end
