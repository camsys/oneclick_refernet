require 'spec_helper'

module OneclickRefernet
  RSpec.describe SubSubCategory, type: :model do
    let(:sub_sub_category) { create(:sub_sub_category, :with_sub_category, :with_services) }

    # Attributes
    it { should respond_to :name }
    
    # Class Methods
    it { SubSubCategory.should respond_to(:fetch_by_sub_category).with(1).argument }
    
    # Associations
    it { should have_one(:category) }
    it { should belong_to(:sub_category) }
    it { should have_many(:services_sub_sub_categories).dependent(:destroy) }
    it { should have_many(:services).through(:services_sub_sub_categories) }

    # Shared categorical module examples
    it_behaves_like "categorical"
    it_behaves_like "confirmable"
        
  end
end
