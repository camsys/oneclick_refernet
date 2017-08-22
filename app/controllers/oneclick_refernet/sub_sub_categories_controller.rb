module OneclickRefernet
  class SubSubCategoriesController < ApplicationController
    
    def index
      @sub_category = SubCategory.find_by(name: params[:sub_category])
      
      render json: (@sub_category.try(:sub_sub_categories) || [])
    end
    
  end
end
