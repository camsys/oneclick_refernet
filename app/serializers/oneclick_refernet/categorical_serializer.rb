# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class CategoricalSerializer < ActiveModel::Serializer
    
    attributes :name, :service_count

    def name
      object.translated_name(scope[:locale] || "en")
    end

    def service_count
      object.service_count(28.540375, -81.373170, 30000)
    end
    
  end
end
