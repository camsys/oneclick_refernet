module OneclickRefernet
  module Categorical
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true #, uniqueness: true
    end

    def service_count lat=nil, lng=nil, meters=nil
      if lat and lng and meters
        services.within_box(lat, lng, meters).count
      else
        services.count
      end
    end

  end
end
