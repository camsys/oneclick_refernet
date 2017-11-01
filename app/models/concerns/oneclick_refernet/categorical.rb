module OneclickRefernet
  module Categorical
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true #, uniqueness: true
    end

    def service_count lat=nil, lng=nil, meters=30000

      puts meters 
      puts 'Derek'
      if lat and lng
        services.within_box(lat, lng, meters).count
      else
        services.count
      end
    end

  end
end
