module OneclickRefernet
  class CategoriesController < ApplicationController
    
    def index
      render json: Category.all
    end
    
  end
end
