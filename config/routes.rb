Propeller::Engine.routes.draw do
  root to: "worker_jobs#index"

  get "all"                => "worker_jobs#all"
  get "completed"          => "worker_jobs#completed"
  get "queued"             => "worker_jobs#queued"
  get "failed"             => "worker_jobs#failed"
  get "retired"            => "worker_jobs#retired"
  get "counts"             => "worker_jobs#counts",             as: :counts

  get "completed/daily"    => "worker_jobs/completed#daily",    as: :daily_completed
  get "completed/hourly"   => "worker_jobs/completed#hourly",   as: :hourly_completed
  get "completed/minutely" => "worker_jobs/completed#minutely", as: :minutely_completed

  get "failures"           => "worker_jobs/failures#index"
  get "failures/:id"       => "worker_jobs/failures#show",      as: :job_failures
end
