require 'spec_helper'

module OneclickRefernet

  RSpec.shared_examples "confirmable" do

    let(:factory) { factory_from_class(described_class) }
    before(:each) do 
      3.times do 
        create(factory, confirmed: true) # Create a bunch of confirmeds
        create(factory, confirmed: false) # Create a bunch of unconfirmeds
      end
    end
    let(:confirmed_ids) { described_class.confirmed.pluck(:id) }
    let(:unconfirmed_ids) { described_class.unconfirmed.pluck(:id) }
    
    # Attributes
    it { should respond_to :confirmed }
    
    # Class Methods & Scopes
    it { described_class.should respond_to :confirm_all,
          :unconfirm_all, :destroy_confirmed, :destroy_unconfirmed,
          :confirm_unconfirmed, :approve_changes, :reject_changes,
          :confirmed, :unconfirmed }
    
    it "approves changes" do
      expect(described_class.confirmed.pluck(:id)).to eq(confirmed_ids)
      expect(described_class.unconfirmed.pluck(:id)).to eq(unconfirmed_ids)      
      expect(described_class.confirmed.count).to eq(3)
      expect(described_class.unconfirmed.count).to eq(3)
            
      described_class.approve_changes
      
      expect(described_class.confirmed.count).to eq(3)
      expect(described_class.unconfirmed.count).to eq(0)      
      expect(described_class.confirmed.pluck(:id)).to eq(unconfirmed_ids)
    end
    
    it "rejects changes" do
      expect(described_class.confirmed.pluck(:id)).to eq(confirmed_ids)
      expect(described_class.unconfirmed.pluck(:id)).to eq(unconfirmed_ids)      
      expect(described_class.confirmed.count).to eq(3)
      expect(described_class.unconfirmed.count).to eq(3)
      
      described_class.reject_changes      
      expect(described_class.confirmed.count).to eq(3)
      expect(described_class.unconfirmed.count).to eq(0)      
      expect(described_class.confirmed.pluck(:id)).to eq(confirmed_ids)
    end
    
  end
end
