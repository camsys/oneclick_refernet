module OneclickRefernet
  module Categorical
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true #, uniqueness: true      
    end

    # Counts the services under a given category. If lat and lng are passed,
    # counts them within given radius of that point, defaulting to 30 miles
    def service_count lat=nil, lng=nil, meters=30*1609.34
      if lat && lng
        services.within_x_meters(lat, lng, meters).count
      else
        services.count
      end
    end

  end
end
