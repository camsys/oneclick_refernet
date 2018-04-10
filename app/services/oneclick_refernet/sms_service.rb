module OneclickRefernet
  class SmsService

    def send(phone, services, locale)
      @services = OneclickRefernet::Service.find(services).map do |result|
        OneclickRefernet::ServiceSerializer.new(
          result, 
          scope: { locale: locale || "en"}
        ).serializable_hash
      end
      I18n.locale = locale
     
      sns = Aws::SNS::Client.new(
        region: ENV['AWS_ACCESS_KEY_ID'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'] , 
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
     
      sns.publish({phone_number: '+14233092124', message: 'test message'})

    end #Send

  end #SmsService
end #OneclickRefernet