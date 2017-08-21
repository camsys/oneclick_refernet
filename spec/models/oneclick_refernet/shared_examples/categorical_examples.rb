require 'spec_helper'

module OneclickRefernet
  RSpec.shared_examples "categorical" do
    let(:factory) { described_class.to_s.underscore.to_sym }
    
    it { should validate_presence_of :name }
    it { should respond_to :service_count }
    
    pending "counts number of associated services"
    
  end
end
