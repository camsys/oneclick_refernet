# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class CategoricalSerializer < ActiveModel::Serializer
    
    attributes :name, :service_count

    def name
      object.translated_name(scope[:locale] || "en")
    end

    def service_count
      object.service_count(scope[:lat], scope[:lng] 30000)
    end
    
  end
end
