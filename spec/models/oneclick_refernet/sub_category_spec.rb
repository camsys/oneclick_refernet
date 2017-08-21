require 'spec_helper'

module OneclickRefernet
  RSpec.describe SubCategory, type: :model do
    let(:sub_category) { create(:sub_category, :with_category) }

    # Attributes
    it { should respond_to :name, :refernet_category_id }
    
    # Class Methods
    it { SubCategory.should respond_to(:fetch_by_category).with(1).argument }
    
    # Associations
    it { should belong_to(:category) }
    it { should have_many(:sub_sub_categories).dependent(:destroy) }
    it { should have_many(:services).through(:sub_sub_categories) }

    # Shared categorical module examples
    it_behaves_like "categorical"
    it_behaves_like "confirmable"

  end
end
