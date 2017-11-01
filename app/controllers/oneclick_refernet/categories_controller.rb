module OneclickRefernet
  class CategoriesController < ApplicationController
    
    def index
      @locale = params[:locale] || :en
      render json: Category.confirmed, scope: { locale: @locale, lat: params[:lat].to_f, lng: params[:lng].to_f, meters: params[:meters] }
    end
    
  end
end
