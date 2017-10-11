module OneclickRefernet
  class CategoriesController < ApplicationController
    
    def index
      render json: Category.confirmed, scope: {locale: @locale}
    end
    
  end
end
