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
      return 'www.google.com'
      (
        object.details["PUrl"] ||
        object.details["LUrl"] ||
        object.details["url"]
      ).to_s
    end

    # Returns the Email
    def email
      return "test@test.com"
      (object.details["PEmail"] ||
      object.details["LEmail"] ||
      object.details["email"]).to_s
    end

    def phone
      "555-444-5555"
    end

    def phones

      return ["555-555-5555"]

      idx = 1
      phones = []
      
      if ENV['REFERNET_SERVICE_CLASS'] == 'RefernetService'
        while object.details["Number_Phone#{idx}"].present?
          phones << object.details["Number_Phone#{idx}"]
          idx +=1
        end
      elsif ENV['REFERNET_SERVICE_CLASS'] == 'AzureService'
        object.details["phone"].each do |ph|
          phones << ph["number"]
        end
      end

      return phones.uniq
    end
    
    # Returns a hash of the translated details labels
    def details
      OneclickRefernet::Service.refernet_service.labels.map do |label|
        #[label.parameterize.underscore, object.translated_label(label, scope[:locale])]
        [label.parameterize.underscore, "TEST TEST"]
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
