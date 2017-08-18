require 'pg'
require 'rgeo'
require 'activerecord-postgis-adapter'

module OneclickRefernet
  class Engine < ::Rails::Engine
    isolate_namespace OneclickRefernet

  end
end
