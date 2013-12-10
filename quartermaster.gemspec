$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "quartermaster/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "quartermaster"
  s.version     = Quartermaster::VERSION
  s.authors     = ["Farley Knight"]
  s.email       = ["farleyknight@gmail.com"]
  s.homepage    = "http://github.com/farleyknight/quartermaster"
  s.summary     = "Database-backed job queue system with throttling."
  s.description = "Database-backed job queue system with throttling."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "lumberjack"
  s.add_dependency "twitter-bootstrap-rails"
end
