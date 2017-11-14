module OneclickRefernet
  class SearchController < ApplicationController
    
    # GET /search
    def search
      @locale = params[:locale] || I18n.default_locale
      @results = OneclickRefernet::KeywordSearcher.new.search(params[:term])
      
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
