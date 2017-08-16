module OneclickRefernet
  class Category < ApplicationRecord
    include OneclickRefernet::Categorical
    include OneclickRefernet::Confirmable
    
    has_many :sub_categories
    has_many :sub_sub_categories, through: :sub_categories
    has_many :services, through: :sub_sub_categories

  end
end
