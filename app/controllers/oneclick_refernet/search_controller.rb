module OneclickRefernet
  class SearchController < ApplicationController
    
    # GET /search
    def search
      @results = OneclickRefernet::KeywordSearcher.new.search(params[:term])
      serialized_results = @results.map do |result|
        OneclickRefernet::SearchResultSerializer.new(result).serializable_hash
      end
                            
      render json: { results: serialized_results }
    end
    
  end
end
