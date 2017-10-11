module OneclickRefernet
  class SubCategoriesController < ApplicationController
    
    def index
      @category = Category.find_by(name: params[:category])
      render json: (@category.try(:sub_categories).try(:confirmed) || []), scope: {locale: @locale}
    end
    
  end
end
