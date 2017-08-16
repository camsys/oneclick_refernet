module OneclickRefernet
  class SubCategory < ApplicationRecord
    include OneclickRefernet::Categorical
    include OneclickRefernet::Confirmable
    
    belongs_to :category
    has_many :sub_sub_categories
    has_many :services, through: :sub_sub_categories
  end
end
