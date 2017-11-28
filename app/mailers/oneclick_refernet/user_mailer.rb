module OneclickRefernet
  class UserMailer < ApplicationMailer

    def services(email,services)
      @services = OneclickRefernet::Service.find(services).map do |result|
        OneclickRefernet::ServiceSerializer.new(
          result, 
          scope: { locale: @locale}
        ).serializable_hash
      end
      @services.each do |s|
        puts s.ai  
      end
      mail(to: email, subject: "TRANSLATE ME").deliver
    end
  end
end
