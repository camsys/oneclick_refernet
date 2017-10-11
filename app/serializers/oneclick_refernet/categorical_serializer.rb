# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class CategoricalSerializer < ActiveModel::Serializer
    
    attributes :name, :service_count

    def name
      object.translated_name(scope[:locale] || "en")
    end
    
  end
end
