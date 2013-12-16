class CreateWorkerJobs < ActiveRecord::Migration
  def change
    create_table :worker_jobs do |t|
      t.timestamp :started_at
      t.timestamp :ended_at
      t.datetime :started_at_beginning_of_minute
      t.datetime :started_at_beginning_of_hour
      t.date :started_at_beginning_of_day
      t.string :status
      t.datetime :scheduled_for
      t.datetime :scheduled_for_date

      t.timestamps
    end
  end
end
