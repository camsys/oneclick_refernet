module OneclickRefernet
  class ServiceSerializer < ActiveModel::Serializer
    
    attributes :agency_name,
               :site_name,
               :lat,
               :lng,
               :address,
               :url,
               :phone,
               :description

        # Get whatever URL is available, and prepend http:// if necessary
        def url
        	url_str = (object.details["url"] ||
          object.details["PUrl"] ||
          object.details["LUrl"]).to_s
          
          scheme = (url_str.match(/([a-zA-Z][\-+.a-zA-Z\d]*):.*$/).try(:captures) || [])[0]
          url_str = "http://" + url_str unless scheme.present?
          return url_str
        end
        
        def phone
          object.details["Number_Phone1"] ||
          object.details["Number_Phone2"] ||
          object.details["Number_Phone3"]          
        end
    
  end
end
