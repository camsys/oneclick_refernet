require 'spec_helper'

module OneclickRefernet
  RSpec.describe Category, type: :model do
    let(:category) { create(:category) }

    # Attributes
    it { should respond_to :name }
    
    # Class Methods
    it { Category.should respond_to :fetch_all }
    
    # Associations
    it { should have_many(:sub_categories).dependent(:destroy) }
    it { should have_many(:sub_sub_categories).through(:sub_categories) }
    it { should have_many(:services).through(:sub_sub_categories) }

    # Shared categorical module examples
    it_behaves_like "categorical"
    it_behaves_like "confirmable"

  end
end
