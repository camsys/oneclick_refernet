require 'spec_helper'

module OneclickRefernet
  RSpec.describe Category, type: :model do
    let(:category) { create(:category) }
    
    # Attributes
    it { expect respond_to :name }
    
    # Class Methods
    it { expect(Category).to respond_to :fetch_all }
    
    # Associations
    it { expect have_many(:sub_categories).dependent(:destroy) }
    it { expect have_many(:sub_sub_categories).through(:sub_categories) }
    it { expect have_many(:services).through(:sub_sub_categories) }

    # Shared categorical module examples
    it_behaves_like "categorical"
    it_behaves_like "confirmable"
    
    # Stub RefernetService methods
    before(:each) { stub_refernet_service }
    
    it "fetches all categories from refernet" do
      categories = Category.fetch_all
      expect(categories.count).to eq(3)
      expect(categories.all? {|c| c.is_a?(OneclickRefernet::Category)}).to be true
      expect( categories.map {|c| c.name } - 
              RefernetService.new.get_categories.map{|c| c["Category_Name"]}
            ).to eq([])
    end

  end
end
