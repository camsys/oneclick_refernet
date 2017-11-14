module OneclickRefernet
  class SubCategoriesController < ApplicationController
    
    def index
      @locale = params[:locale] || I18n.default_locale
      @category = Category.find_by(code: params[:category])
      render json: (@category.try(:sub_categories).try(:confirmed) || []), 
             scope: {locale: @locale, lat: params[:lat], lng: params[:lng], meters: (params[:meters] || 48280.3).to_f}
    end
    
  end
end
