require 'spec_helper'

module OneclickRefernet
  RSpec.describe CategoriesController, type: :controller do
    routes { OneclickRefernet::Engine.routes }

    before(:each) { rand(1..5).times { create(:category) } }

    it "returns all categories" do
      get :index
      expect(response).to be_success
      response_body = JSON.parse(response.body)
      expect(response_body.count).to eq(Category.count)
      expect(response_body.map {|c| c["name"]}.sort).to eq(Category.all.pluck(:name).sort)
    end

  end
end
