# Quartermaster


## Installation

Run `rails g quartermaster:install` and you'll get:

### Initializer

This file configures Quartermaster for your setup:

```ruby
Quartermaster.config do |c|
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

This line adds the Quartermaster admin panel `config/routes.rb`:

```ruby
MyApp::Application.routes.draw do
  mount Quartermaster::Engine => "/quartermaster"
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
    t.datetime  "scheduled_at"
    t.date      "scheduled_at_date"
    t.date      "started_at_beginning_of_day"
  end
```

