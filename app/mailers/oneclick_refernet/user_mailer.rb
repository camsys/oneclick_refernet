module OneclickRefernet
  class UserMailer < ApplicationMailer

    def services(email, services, locale)
      @services = OneclickRefernet::Service.find(services).map do |result|
        OneclickRefernet::ServiceSerializer.new(
          result, 
          scope: { locale: @locale}
        ).serializable_hash
      end
      I18n.locale = locale
      mail(to: email, subject: I18n('services')).deliver
    end
  end
end
