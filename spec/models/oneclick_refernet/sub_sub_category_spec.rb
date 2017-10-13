require 'spec_helper'

module OneclickRefernet
  RSpec.describe SubSubCategory, type: :model do
    let(:sub_sub_category) { create(:sub_sub_category, :with_sub_category, :with_services) }
    let(:sub_category) { create(:sub_category, refernet_category_id: 999)}

    # Attributes
    it { expect respond_to :name }
    
    # Class Methods
    it { expect(SubSubCategory).to respond_to(:fetch_by_sub_category).with(1).argument }
    
    # Associations
    it { expect have_one(:category) }
    it { expect belong_to(:sub_category) }
    it { expect have_many(:services_sub_sub_categories).dependent(:destroy) }
    it { expect have_many(:services).through(:services_sub_sub_categories) }

    # Shared categorical module examples
    it_behaves_like "categorical"
    it_behaves_like "confirmable"
            
    # Stub RefernetService methods
    before(:each) { stub_refernet_service }
    
    it "fetches sub-sub-categories from refernet by sub-category" do      
      sub_sub_cats = SubSubCategory.fetch_by_sub_category(sub_category)
      expect(sub_sub_cats.count).to eq(5)
      expect(sub_sub_cats.all? {|ssc| ssc.is_a?(OneclickRefernet::SubSubCategory)}).to be true
      expect(sub_sub_cats.map {|ssc| ssc.name } - 
              RefernetService.new.get_sub_sub_categories(999).map{|ssc| ssc["Name"]}
            ).to eq([])      
    end    
        
  end
end
