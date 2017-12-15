module OneclickRefernet
  class ServicesController < ApplicationController
    
    def index
      @sub_sub_category = SubSubCategory.find_by(code: params[:sub_sub_category])
      render json: (@sub_sub_category.try(:services).try(:confirmed) || []), 
             scope: {locale: @locale}
    end
    
    # GET services/:id
    # GET services/details
    # Gets service details by ID or by ReferNET service_id and location_id
    def show      
      if params[:id].to_i.nonzero?
        @service = OneclickRefernet::Service.find_by(id: params[:id])
      elsif params[:service_id] && params[:location_id]
        @service = OneclickRefernet::Service.find_by(
          refernet_service_id: params[:service_id], 
          refernet_location_id: params[:location_id])
      end
      
      render json: @service, 
             scope: {locale: @locale}      
    end
    
  end
end
