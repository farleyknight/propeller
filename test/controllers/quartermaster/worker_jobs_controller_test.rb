require 'test_helper'

module Quartermaster
  class WorkerJobsControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end

  end
end
