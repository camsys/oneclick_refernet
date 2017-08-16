module OneclickRefernet
  class SubSubCategory < ApplicationRecord
    belongs_to :sub_category
    has_one :category, through: :sub_category
    has_many :services
  end
end
