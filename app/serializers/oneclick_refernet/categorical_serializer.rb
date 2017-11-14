# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class CategoricalSerializer < ActiveModel::Serializer
    
    attributes :code, :name, :service_count

    # Name returns the translated name of the category
    def name
      object.translated_name(scope[:locale] || I18n.default_locale)
    end

    def service_count
      object.service_count(scope[:lat], scope[:lng], scope[:meters])
    end
    
  end
end
