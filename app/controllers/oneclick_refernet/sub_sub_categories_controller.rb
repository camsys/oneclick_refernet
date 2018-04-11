module OneclickRefernet
  class SubSubCategoriesController < RefernetBaseController
    
    def index
      @sub_category = SubCategory.find_by(code: params[:sub_category])
      render json: (@sub_category.try(:sub_sub_categories).try(:confirmed) || []), 
             scope: {locale: @locale, lat: params[:lat], lng: params[:lng], meters: (params[:meters] || 48280.3).to_f}
    end
    
    def show
      @sub_sub_category = SubSubCategory.find_by(code: params[:code])
      render json: @sub_sub_category, scope: { locale: @locale }
    end
    
  end
end
