module OneclickRefernet
  class CategoriesController < RefernetBaseController
    
    def index
      render json: Category.confirmed, scope: { locale: @locale, lat: params[:lat], lng: params[:lng], meters: ((params[:meters] || 48280.3).to_f) }
    end
    
    def show
      @category = Category.find_by(code: params[:code])
      render json: @category, scope: { locale: @locale }
    end
    
  end
end
