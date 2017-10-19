# Serializer for sending back keyword search results, which may be category or service models
module OneclickRefernet
  class SearchResultSerializer < ActiveModel::Serializer
    
    attributes :id, :type, :label, :score
    
    belongs_to :result { object.result }
    
    # Result record id
    def id
      object.result.id
    end
    
    # Result model class name
    def type
      return object.result.class.name
    end

    # Label the result differently depending on its model class
    def label
      case object.result.class.name
      when "OneclickRefernet::Category", 
           "OneclickRefernet::SubCategory", 
           "OneclickRefernet::SubSubCategory"
        return object.result.name
      when "OneclickRefernet::Service"
        return object.result.site_name || object.result.agency_name
      else
        return object.result.to_s
      end
    end
    
    # Search result match score
    def score
      object.score
    end
    
  end
end
