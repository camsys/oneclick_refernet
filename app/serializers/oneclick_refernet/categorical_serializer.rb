# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class CategoricalSerializer < ActiveModel::Serializer
    
    attributes :name, :service_count
    
  end
end
