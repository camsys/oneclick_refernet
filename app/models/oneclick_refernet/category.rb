module OneclickRefernet
  class Category < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Categorical
    include OneclickRefernet::Confirmable
    include OneclickRefernet::RefernetServiceable
    include OneclickRefernet::CategoryTranslatable
    
    ### ASSOCIATIONS ###
    has_many :sub_categories, dependent: :destroy
    has_many :sub_sub_categories, through: :sub_categories
    has_many :services, through: :sub_sub_categories
        
    ### CLASS METHODS ###
    
    # Downloads categories from ReferNET
    def self.fetch_all  
      refernet_service
      .get_categories.map do |cat|
        name = cat["Category_Name"]
        next nil unless name.present?
        Rails.logger.info "Building new category with name: #{name}"
        self.new(
          name: name, 
          code: name.to_s.strip.parameterize.underscore, # Convert name to a snake case code string
          confirmed: false
        )
      end.compact
    end

  end
end
