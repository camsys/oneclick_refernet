module OneclickRefernet
  class ServicesController < ApplicationController
    
    def index
      @sub_sub_category = SubSubCategory.find_by(name: params[:sub_sub_category])
      
      render json: (@sub_sub_category.try(:services).try(:confirmed) || [])
    end
    
  end
end
