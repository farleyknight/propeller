require_dependency "quartermaster/application_controller"

module Quartermaster
  class WorkerJobsController < ApplicationController
    def index
    end

    def counts
      render json: WorkerJob.group(:status).count.to_a
    end
  end
end
