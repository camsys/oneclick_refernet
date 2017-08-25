# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class ServiceSerializer < ActiveModel::Serializer
    
    attributes :name,
               :site_name,
               :formatted_address,
               :address_components,
               :geometry
               

    def name
    	object.site_name
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
        address_components << {long_name: object.details['City'], short_name: object.details['City'], types: ["locality", "political"]}
      end

      #State
      if object.state
        address_components << {long_name: object.details['ZipCode'], short_name: object.details['ZipCode'], types: ["postal_code"]}
      end

      #Zip
      if object.zip
        address_components << {long_name: object.details['State'], short_name: object.details['State'], types: ["administrative_area_level_1","political"]}
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
