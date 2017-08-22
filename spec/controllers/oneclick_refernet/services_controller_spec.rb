require 'spec_helper'

module OneclickRefernet
  RSpec.describe ServicesController, type: :controller do
    routes { OneclickRefernet::Engine.routes }
    
    before(:each) { rand(1..5).times { create(:sub_sub_category, :with_services) } }

    it "returns services for a sub-sub-category" do
      get :index, params: { sub_sub_category: SubSubCategory.first.name }
      expect(response).to be_success
      response_body = JSON.parse(response.body)
      
      services = SubSubCategory.first.services
      expect(response_body.count).to eq(services.count)
      expect(response_body.map {|svc| svc["agency_name"]}.sort).to eq(services.pluck(:agency_name).sort)
    end

  end
end
