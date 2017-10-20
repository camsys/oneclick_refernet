# Module for searching across refernet services and categories by key word
module OneclickRefernet
	
  # KeywordSearcher class returns results across Category and Service tables based on a search term
  class KeywordSearcher
		SEARCHES = [
			{ table: OneclickRefernet::Category, columns: [:name] },
			{ table: OneclickRefernet::SubCategory, columns: [:name] },
			{ table: OneclickRefernet::SubSubCategory, columns: [:name] },
			{ table: OneclickRefernet::Service, columns: [:site_name, :agency_name, :description] }
		].freeze
		
    def initialize(opts={})
			@opts = opts
			@limit = opts[:limit] || 100 # By default, limit search to 10 results
    end
    
    # Search method takes a keyword string and searches across all configured tables/columns
    def search(term)
			return [] unless term
			
			# Combine the searches for the various columns and tables into one array
			return SEARCHES.flat_map do |search| 
				search_table_column(search[:table], search[:columns], term).to_a
			end.take(@limit) # Limit the results
    end
		
		# Searches a given table and columns for the search term
		def search_table_column(table, columns, term)
			# Find all the records that match the search term with any of the columns
			ids = columns.flat_map do |column|				
				table
				.where("#{column} ILIKE ?", "%#{term}%") # Match term using ILIKE query, which is case-insensitive (postgresql only) 
				.pluck(:id) # Pull out the ids of matching results
			end.uniq # Eliminate duplicate entries
			
			# Return tables that came up in any of the column queries
			table
			.where(id: ids)
			.limit(@limit) # Limit number of results
		end
    
  end
    

end
