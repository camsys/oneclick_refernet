# Serializer for sending back keyword search results, which may be category or service models
module OneclickRefernet
  class SearchResultSerializer < ActiveModel::Serializer
    
    attributes :id, :type, :label
    
    belongs_to :result do
      object
    end
    
    # Result record id
    def id
      object.id
    end
    
    # Result model class name
    def type
      return object.class.name
    end

    # Label the result differently depending on its model class
    def label
      case object.class.name
      when "OneclickRefernet::Category", 
           "OneclickRefernet::SubCategory", 
           "OneclickRefernet::SubSubCategory"
        return object.name
      when "OneclickRefernet::Service"
        return object.site_name || object.agency_name
      else
        return object.to_s
      end
    end
    
  end
end
