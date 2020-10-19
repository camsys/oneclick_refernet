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
               :email,
               :display_url,
               :phone,
               :phones,
               :details,
               :service_id,
               :location_id
               
    # Pulls the refernet Service_ID out of the details hash
    def refernet_id
      object.refernet_service_id
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
      (
        object.details["PUrl"] ||
        object.details["LUrl"] ||
        object.details["url"]
      ).to_s
    end

    # Returns the Email
    def email
      (object.details["PEmail"] ||
      object.details["LEmail"] ||
      object.details["email"]).to_s
    end

    def phones
      
      idx = 1
      phones = []
      
      if false #DEREK
        while object.details["Number_Phone#{idx}"].present?
          phones << object.details["Number_Phone#{idx}"]
          idx +=1
        end
      elsif true #DEREK
        object.details["phone"].each do |ph|
          phones << ph["number"]
        end
      end

      return phones
    end
    
    # Returns a hash of the translated details labels
    def details
      OneclickRefernet::Service.refernet_service.labels.map do |label|
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
