module OneclickRefernet
  class CategoriesController < ApplicationController
    
    def index
      render json: Category.confirmed
    end
    
  end
end
