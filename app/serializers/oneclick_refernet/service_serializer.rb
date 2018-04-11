module OneclickRefernet
  class ServiceSerializer < ActiveModel::Serializer
    
    attributes :id,
               :refernet_id,
               :agency_name,
               :site_name,
               :lat,
               :lng,
               :address,
               :url,
               :display_url,
               :phone,
               :details,
               :service_id,
               :location_id
               
    # Pulls the refernet Service_ID out of the details hash
    def refernet_id
      object.details["Service_ID"]
    end

    # Get whatever URL is available, and prepend http:// if necessary
    def url
    	url_str = display_url
      
      scheme = (url_str.match(/([a-zA-Z][\-+.a-zA-Z\d]*):.*$/).try(:captures) || [])[0]
      url_str = "http://" + url_str unless scheme.present?
      return url_str
    end
    
    # Returns the URL without http:// on the front
    def display_url
      (object.details["url"] ||
      object.details["PUrl"] ||
      object.details["LUrl"]).to_s
    end

    # Returns whatever phone number can be found
    def phone
      object.details["Number_Phone1"] ||
      object.details["Number_Phone2"] ||
      object.details["Number_Phone3"]          
    end
    
    # Returns a hash of the translated details labels
    def details
      OneclickRefernet::Service::LABELS.map do |label| 
        [label.parameterize.underscore, object.translated_label(label, scope[:locale])]
      end.to_h
    end
    
    def service_id
      object.refernet_service_id
    end
    
    def location_id
      object.refernet_location_id
    end
    
  end
end
