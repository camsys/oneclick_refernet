module OneclickRefernet
  class SubSubCategoriesController < ApplicationController
    
    def index
      @locale = params[:locale] || :en
      @sub_category = SubCategory.find_by(name: params[:sub_category])
      render json: (@sub_category.try(:sub_sub_categories).try(:confirmed) || []), 
             scope: {locale: @locale, lat: params[:lat], lng: params[:lng], meters: (params[:meters] || 48280.3).to_f}
    end
    
  end
end
