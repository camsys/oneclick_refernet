# Parent class for category, sub-category, and sub-sub-category serializers
module OneclickRefernet
  class CategoricalSerializer < ActiveModel::Serializer
    
    attributes :name, :service_count

    def name
    	puts 'derek derek'
    	puts scope.ai 
    	
      object.translated_name(scope[:locale])
    end
    
  end
end
