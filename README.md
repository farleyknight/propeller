# Propeller

## Installation

Run `rails g propeller:install` and you'll get:

### Initializer

This file configures Propeller for your setup:

```ruby
Propeller.config do |c|
  c.worker_job_class_name = "WorkerJob"
  c.throttle_limits       = {
    1.minute => 14
  }
  c.polling_interval      = 2.seconds
  c.throttle_interval     = 1.second
  c.idle_period           = 5.minutes
end
```

### Admin Panel

This line adds the Propeller admin panel `config/routes.rb`:

```ruby
MyApp::Application.routes.draw do
  mount Propeller::Engine => "/propeller"
end
```

### Worker Job table

This is how your jobs table will look in the database:

```ruby
  create_table "worker_jobs", force: true do |t|
    t.timestamp "created_at",          null: false
    t.timestamp "updated_at",          null: false
    t.timestamp "started_at",          null: false
    t.timestamp "ended_at",            null: false
    t.datetime  "started_at_beginning_of_hour"
    t.datetime  "started_at_beginning_of_minute"
    t.string    "status"
    t.datetime  "scheduled_for"
    t.date      "scheduled_for_date"
    t.date      "started_at_beginning_of_day"
  end
```

### Job Failures table

Whenever a job fails, it'll get logged to the database as well:

```ruby
  create_table "job_failures", force: true do |t|
    t.integer  "worker_job_id"
    t.string   "error_class"
    t.text     "backtrace"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
```

## Running tests

To run the propeller tests, run:

```bash
rake spec
```
