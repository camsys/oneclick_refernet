module OneclickRefernet
  class SubCategory < ApplicationRecord
    belongs_to :category
    has_many :sub_sub_categories
    has_many :services, through: :sub_sub_categories
  end
end
