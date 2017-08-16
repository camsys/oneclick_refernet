module OneclickRefernet
  class Category < ApplicationRecord
    has_many :sub_categories
    has_many :sub_sub_categories, through: :sub_categories
    has_many :services, through: :sub_sub_categories
  end
end
