require 'spec_helper'

module OneclickRefernet
  RSpec.describe ServicesSubSubCategory, type: :model do

    # Associations
    it { should belong_to(:service) }
    it { should belong_to(:sub_sub_category) }

  end
end
