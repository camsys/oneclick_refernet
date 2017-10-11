module OneclickRefernet
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :get_locale 

    def get_locale
    	@locale = params[:locale] || :en
    end
  end
end
