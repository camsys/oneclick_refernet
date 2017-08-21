ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl_rails'
require 'support/factory_girl'
require 'shoulda/matchers'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Require shared examples files
Dir["#{File.dirname(__FILE__)}/models/oneclick_refernet/shared_examples/**/*.rb"].each {|f| require f}

# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

# Configure RSpec
RSpec.configure do |config|
 config.mock_with :rspec
 config.use_transactional_fixtures = true
 config.infer_base_class_for_anonymous_controllers = false
 config.order = "random"
 
 config.before(:all) do
   FactoryGirl.definition_file_paths = %w(spec/factories/oneclick_refernet) # Load the factories directory
   FactoryGirl.reload # Reload factory definitions
 end
end

# Configure shoulda matchers
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    with.library :rails
  end
end
