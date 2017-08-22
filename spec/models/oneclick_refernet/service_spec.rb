require 'spec_helper'

module OneclickRefernet
  RSpec.describe Service, type: :model do
    let(:service) { create(:service) }
    let(:sub_sub_category) { create(:sub_sub_category, name: "Test SubSubCategory") }

    # Associations
    it { expect have_many(:services_sub_sub_categories).dependent(:destroy) }
    it { expect have_many(:sub_sub_categories).through(:services_sub_sub_categories) }
    it { expect have_many(:sub_categories).through(:sub_sub_categories) }
    it { expect have_many(:categories).through(:sub_categories) }
    
    # Attributes
    it { expect respond_to :site_name, :agency_name, :latlng, :details }
    
    # Instance Methods
    it { expect respond_to :address, :lat, :lng }
    
    # Class Methods
    it { expect(Service).to respond_to(:fetch_by_sub_sub_category).with(1).argument }

    # Stub RefernetService methods
    before(:each) { stub_refernet_service }

    it "fetches services from refernet by sub-sub-category" do
      services = Service.fetch_by_sub_sub_category(sub_sub_category)
      expect(services.count).to eq(1)
      expect(services.all? {|svc| svc.is_a?(OneclickRefernet::Service)}).to be true
      expect(services.map {|svc| svc.agency_name } - 
              RefernetService.new.get_services_by_category_and_county("Test SubSubCategory").map{|svc| svc["Name_Agency"]}
            ).to eq([])      
    end
    
  end
end
