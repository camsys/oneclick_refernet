module OneclickRefernet
  class SubCategoriesController < RefernetBaseController
    
    def index
      @category = Category.find_by(code: params[:category])
      render json: (@category.try(:sub_categories).try(:confirmed) || []), 
             scope: {locale: @locale, lat: params[:lat], lng: params[:lng], meters: (params[:meters] || 48280.3).to_f}
    end
    
    def show
      @sub_category = SubCategory.find_by(code: params[:code])
      render json: @sub_category, scope: { locale: @locale }
    end
    
  end
end
