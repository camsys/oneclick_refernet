require 'pg'
require 'rgeo'
require 'activerecord-postgis-adapter'
require 'active_model_serializers'

module OneclickRefernet
  class Engine < ::Rails::Engine
    isolate_namespace OneclickRefernet

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
    
  end
end
