module OneclickRefernet
  class UserMailer < ApplicationMailer

    def services(email, services, locale)
      @services = OneclickRefernet::Service.find(services).map do |result|
        OneclickRefernet::ServiceSerializer.new(
          result, 
          scope: { locale: locale || "en"}
        ).serializable_hash
      end
      I18n.locale = locale
      mail(to: email, subject: I18n.translate('services'))
    end
  end
end
