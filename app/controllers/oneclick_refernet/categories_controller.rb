module OneclickRefernet
  class CategoriesController < ApplicationController
    
    def index
      @locale = params[:locale] || :en
      render json: Category.confirmed, scope: {locale: @locale, lat: params[:lat], lng: params[:lng], meters: params[:meters] || 48280.3}
    end
    
  end
end
