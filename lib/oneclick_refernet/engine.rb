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
    
    # Runs migrations from within the engine, rather than requiring them to be installed in the containing app
    initializer :append_migrations do |app|
     unless app.root.to_s.match root.to_s
       puts "ENGINE CONFIG PATHS", config.paths["db/migrate"].expanded.ai
       puts "APP CONFIG PATHS", app.config.paths["db/migrate"].expanded.ai
       
       config.paths["db/migrate"].expanded.each do |expanded_path|
         app.config.paths["db/migrate"] << expanded_path
       end
     end
    end
    
  end
end
