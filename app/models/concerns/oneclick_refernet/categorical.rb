module OneclickRefernet
  module Categorical
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true #, uniqueness: true
      
      # Keyword Search
      searchable do
        text :name, as: :name_subtext
      end
      
    end

    def service_count
      services.count
    end

  end
end
