module OneclickRefernet
  module Categorical
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true #, uniqueness: true      
    end

    def service_count lat=nil, lng=nil, meters=30000
      if lat && lng
        services.within_XX_meters(lat, lng, meters).count
        # services.within_box(lat, lng, meters).count
      else
        services.count
      end
    end

  end
end
