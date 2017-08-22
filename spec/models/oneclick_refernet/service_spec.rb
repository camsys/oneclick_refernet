require 'spec_helper'

module OneclickRefernet
  RSpec.describe Service, type: :model do
    let(:service) { create(:service) }

    # Associations
    it { should have_many(:services_sub_sub_categories).dependent(:destroy) }
    it { should have_many(:sub_sub_categories).through(:services_sub_sub_categories) }
    it { should have_many(:sub_categories).through(:sub_sub_categories) }
    it { should have_many(:categories).through(:sub_categories) }


  end
end
