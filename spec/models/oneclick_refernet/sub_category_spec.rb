require 'spec_helper'

module OneclickRefernet
  RSpec.describe SubCategory, type: :model do
    let(:sub_category) { create(:sub_category, :with_category) }
    let(:category) { create(:category, name: "Test Category") }

    # Attributes
    it { expect respond_to :name, :refernet_category_id }
    
    # Class Methods
    it { expect(SubCategory).to respond_to(:fetch_by_category).with(1).argument }
    
    # Associations
    it { expect belong_to(:category) }
    it { expect have_many(:sub_sub_categories).dependent(:destroy) }
    it { expect have_many(:services).through(:sub_sub_categories) }

    # Shared categorical module examples
    it_behaves_like "categorical"
    it_behaves_like "confirmable"

    # Stub RefernetService methods
    before(:each) { stub_refernet_service }
    
    it "fetches sub-categories from refernet by category" do
      sub_cats = SubCategory.fetch_by_category(category)
      expect(sub_cats.count).to eq(4)
      expect(sub_cats.all? {|sc| sc.is_a?(OneclickRefernet::SubCategory)}).to be true
      expect(sub_cats.map {|sc| sc.name } - 
              RefernetService.new.get_sub_categories("Test Category").map{|sc| sc["Subcategory_Name"]}
            ).to eq([])
    end

  end
end
