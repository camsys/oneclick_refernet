# Module for searching across refernet services and categories by key word
module OneclickRefernet
	
  # KeywordSearcher class returns results across Category and Service tables based on a search term
  class KeywordSearcher
		SEARCHABLE_TABLES = [
			OneclickRefernet::Category,
			OneclickRefernet::SubCategory,
			OneclickRefernet::SubSubCategory,
			OneclickRefernet::Service
		].freeze
		
    def initialize(opts={})
			@opts = opts
    end
    
    # Search method takes a keyword string and searches across all configured tables/columns
    def search(term)
			return [] unless term
			Sunspot.search(SEARCHABLE_TABLES) { fulltext(term) }.hits
    end
    
  end
    

end
