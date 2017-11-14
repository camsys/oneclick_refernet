module OneclickRefernet
  class ServicesController < ApplicationController
    
    def index
      @locale = params[:locale] || I18n.default_locale
      @sub_sub_category = SubSubCategory.find_by(code: params[:sub_sub_category])
      render json: (@sub_sub_category.try(:services).try(:confirmed) || []), 
             scope: {locale: @locale}
    end
    
  end
end
