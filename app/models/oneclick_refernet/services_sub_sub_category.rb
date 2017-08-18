module OneclickRefernet
  class ServicesSubSubCategory < ApplicationRecord
    belongs_to :service, inverse_of: :services_sub_sub_categories
    belongs_to :sub_sub_category, inverse_of: :services_sub_sub_categories
  end
end
