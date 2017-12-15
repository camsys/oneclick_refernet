module OneclickRefernet
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    
    before_action :set_locale
    
    # sets @locale based on passed params, or to default
    def set_locale
      @locale = params[:locale] || I18n.default_locale
    end
    
  end
end
