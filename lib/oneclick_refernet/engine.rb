require 'pg'
require 'rgeo'
require 'activerecord-postgis-adapter'
require 'active_model_serializers'

module OneclickRefernet
  class Engine < ::Rails::Engine
    isolate_namespace OneclickRefernet

  end
end
