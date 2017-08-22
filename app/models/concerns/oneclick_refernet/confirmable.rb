module OneclickRefernet
  module Confirmable
    extend ActiveSupport::Concern
    
    included do
      
      scope :confirmed, -> { where(confirmed: true) }
      scope :unconfirmed, -> { where(confirmed: false) }
      
      def self.confirm_all
        all.update_all(confirmed: true)
      end
      
      def self.unconfirm_all
        all.update_all(confirmed: false)
      end
      
      def self.destroy_confirmed
        confirmed.destroy_all
      end
      
      def self.destroy_unconfirmed
        unconfirmed.destroy_all
      end
      
      def self.confirm_unconfirmed
        unconfirmed.confirm_all
      end
      
      def self.approve_changes
        destroy_confirmed and confirm_unconfirmed
      end
      
      def self.reject_changes
        destroy_unconfirmed
      end
      
    end

  end
end
