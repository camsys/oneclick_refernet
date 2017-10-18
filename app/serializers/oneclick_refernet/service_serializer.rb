module OneclickRefernet
  class ServiceSerializer < ActiveModel::Serializer
    
    attributes :agency_name,
               :site_name,
               :lat,
               :lng,
               :address,
               :url

        def url
        	object.details["url"]
        end
    
  end
end
