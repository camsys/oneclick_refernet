require 'spec_helper'

module OneclickRefernet
  RSpec.shared_examples "confirmable" do
    let(:factory) { described_class.to_s.underscore.to_sym }
    
    # Attributes
    it { should respond_to :confirmed }
    
    # Class Methods & Scopes
    it { described_class.should respond_to :confirm_all,
          :unconfirm_all, :destroy_confirmed, :destroy_unconfirmed,
          :confirm_unconfirmed, :approve_changes, :reject_changes,
          :confirmed, :unconfirmed }
    
    pending "approves changes"
    
    pending "rejects changes"
    
  end
end
