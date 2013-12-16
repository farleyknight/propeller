# Quartermaster


## Installation

Run `rails g quartermaster:install` and you'll get:

### Admin Panel

This line adds the Quartermaster admin panel `config/routes.rb`:

```ruby
MyApp::Application.routes.draw do
  mount Quartermaster::Engine => "/quartermaster"
end
```

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
