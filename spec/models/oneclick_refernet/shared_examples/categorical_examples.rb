require 'spec_helper'

module OneclickRefernet
  
  RSpec.shared_examples "categorical" do
    let(:factory) { factory_from_class(described_class) }
    let(:categorical) { create(factory, :recursive) }
    
    it { should validate_presence_of :name }
    it { should respond_to :service_count }
    
    it "counts number of associated services" do
      expect(categorical.service_count).to eq(Service.count)
    end
    
  end
  
end
