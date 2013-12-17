require 'rails/generators'
require 'rails/generators/resource_helpers'

class Propeller::RoutesGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def add_routes
    route "mount Propeller::Engine => '/propeller'"
  end
end
