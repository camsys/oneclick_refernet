module OneclickRefernet
  module RefernetServiceable
    extend ActiveSupport::Concern

    included do
      def self.refernet_service
        if ENV['REFERNET_SERVICE_CLASS'] == 'RefernetService'
          OneclickRefernet::RefernetService.new
        elsif ENV['REFERNET_SERVICE_CLASS'] == 'AzureService'
          OneclickRefernet::AzureService.new
        end
      end
    end

  end
end
