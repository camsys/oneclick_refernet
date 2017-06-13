$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "oneclick_refernet/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "oneclick_refernet"
  s.version     = OneclickRefernet::VERSION
  s.authors     = ["Derek Edwards"]
  s.email       = ["dedwards8@gmail.com"]
  s.homepage    = "http://occ-lynx-prod.herokuapp.com"
  s.summary     = "Connect Oneclick-Core with ReferNET API."
  s.description = "Adapter between Oneclick-Core and ReferNET"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.3"

  s.add_development_dependency "sqlite3"
end
