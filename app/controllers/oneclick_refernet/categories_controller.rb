module OneclickRefernet
  class CategoriesController < ApplicationController
    
    def index
      puts 'test'
      puts @traveler.ai 
      render json: Category.confirmed
    end
    
  end
end
