desc "Start a quartermaster worker. Provide PIDFILE and WORKER_ID in your command line."
namespace :quartermaster do
  task :run do
    Quartermaster::Worker.start!(ENV)
  end
end
