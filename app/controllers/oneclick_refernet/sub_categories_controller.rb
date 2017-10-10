module OneclickRefernet
  class SubCategoriesController < ApplicationController
    
    def index
      puts 'test'
      puts @traveler.ai 
      @category = Category.find_by(name: params[:category])
      
      render json: (@category.try(:sub_categories).try(:confirmed) || [])
    end
    
  end
end
