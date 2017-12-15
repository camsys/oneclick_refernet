module OneclickRefernet
  class SearchController < ApplicationController
    
    # GET /search
    def search
      @type = params[:type]
      @results = OneclickRefernet::KeywordSearcher.new(type: @type).search(params[:term])
      
      serialized_results = @results.map do |result|
        OneclickRefernet::SearchResultSerializer.new(
          result, 
          scope: { locale: @locale}
        ).serializable_hash
      end
                            
      render json: { results: serialized_results }
    end
    
  end
end
