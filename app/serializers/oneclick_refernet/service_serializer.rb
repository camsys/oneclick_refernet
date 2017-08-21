# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class ServiceSerializer < ActiveModel::Serializer
    
    attributes :agency_name,
               :site_name,
               :lat,
               :lng,
               :address
    
  end
end
