desc "Start a propeller worker. Provide PIDFILE and WORKER_ID in your command line."
namespace :propeller do
  task :run => :environment do
    Propeller::Worker.start!(ENV)
  end
end
