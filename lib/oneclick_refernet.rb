require "oneclick_refernet/engine"

module OneclickRefernet

  # Refernet API Token Config Variable
  mattr_accessor :api_token
  
  # Base controller class to inherit from
  mattr_accessor :base_controller

  # How big of a circle to look for services
  mattr_accessor :default_radius_meters
  
end
