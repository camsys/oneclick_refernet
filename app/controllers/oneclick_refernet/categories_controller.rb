module OneclickRefernet
  class CategoriesController < ApplicationController
    
    def index
      @locale = params[:locale] || :en
      render json: Category.confirmed, scope: {locale: @locale}
    end
    
  end
end
