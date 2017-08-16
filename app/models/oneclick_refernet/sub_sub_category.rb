module OneclickRefernet
  class SubSubCategory < ApplicationRecord
    include OneclickRefernet::Categorical
    include OneclickRefernet::Confirmable
    
    belongs_to :sub_category
    has_one :category, through: :sub_category
    has_many :services
  end
end
