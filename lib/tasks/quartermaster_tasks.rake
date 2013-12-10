desc "Start a quartermaster worker. Provide PIDFILE and WORKER_ID in your command line."
namespace :quartermaster do
  task :run => "app:environment" do
    Quartermaster::Worker.start!(ENV)
  end
end
