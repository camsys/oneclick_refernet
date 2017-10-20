module OneclickRefernet
  module Categorical
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true #, uniqueness: true      
    end

    def service_count
      services.count
    end

  end
end
