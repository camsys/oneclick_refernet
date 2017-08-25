# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class ServiceSerializer < ActiveModel::Serializer
    
    attributes :agency_name,
               :site_name,
               :lat,
               :lng,
               :address,
               :place

    def place
    	formatted_address
    	geometry
    end

    def address_components
      address_components = []

      #street_number
      if object.street_number
        address_components << {long_name: object.street_number, short_name: object.street_number, types: ['street_number']}
      end

      #Route
      if object.route
        address_components << {long_name: object.route, short_name: object.route, types: ['route']}
      end

      #City
      if object.city
        address_components << {long_name: object.city, short_name: object.city, types: ["locality", "political"]}
      end

      #State
      if object.state
        address_components << {long_name: object.zip, short_name: object.zip, types: ["postal_code"]}
      end

      #Zip
      if object.zip
        address_components << {long_name: object.state, short_name: object.state, types: ["administrative_area_level_1","political"]}
      end

      return address_components

    end

    def formatted_address
        object.address
    end

  def geometry
    {
      location: {
        lat: object.lat.to_f,
        lng: object.lng.to_f,
      }
    }
  end

    
  end
end
