module OneclickRefernet
  module RefernetServiceable
    extend ActiveSupport::Concern

    included do
      def self.refernet_service
        OneclickRefernet::RefernetService.new
      end
    end

  end
end
