module OneclickRefernet
  module Categorical
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true #, uniqueness: true
      
      # Keyword Search
      searchable do
        text :name
      end
      
    end

    def service_count
      services.count
    end

  end
end
