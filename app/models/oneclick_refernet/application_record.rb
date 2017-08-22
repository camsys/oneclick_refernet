module OneclickRefernet
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    
    def self.refernet_service
      OneclickRefernet::RefernetService.new
    end
    
  end
end
