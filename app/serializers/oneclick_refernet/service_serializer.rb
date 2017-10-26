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

        def url
        	object.details["url"] ||
          object.details["PUrl"] ||
          object.details["LUrl"]
        end
        
        def phone
          object.details["Number_Phone1"] ||
          object.details["Number_Phone2"] ||
          object.details["Number_Phone3"]          
        end
    
  end
end
