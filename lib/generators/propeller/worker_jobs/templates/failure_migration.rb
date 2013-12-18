class CreateJobFailures < ActiveRecord::Migration
  def change
    create_table "job_failures", force: true do |t|
      t.integer  "worker_job_id"
      t.string   "error_class"
      t.text     "backtrace"
      t.text     "message"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
