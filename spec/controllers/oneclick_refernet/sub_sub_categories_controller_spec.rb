require 'spec_helper'

module OneclickRefernet
  RSpec.describe SubSubCategoriesController, type: :controller do
    routes { OneclickRefernet::Engine.routes }
    
    before(:each) do
      rand(1..5).times { create(:sub_category, :with_sub_sub_categories) }
      SubSubCategory.confirm_all
    end

    it "returns confirmed sub-sub-categories for a sub-category" do
      get :index, params: { sub_category: SubCategory.first.name }
      expect(response).to be_success
      response_body = JSON.parse(response.body)
      
      sub_sub_categories = SubCategory.first.sub_sub_categories.confirmed
      expect(response_body.count).to eq(sub_sub_categories.count)
      expect(response_body.map {|ssc| ssc["name"]}.sort).to eq(sub_sub_categories.pluck(:name).sort)
    end

  end
end
