module OneclickRefernet
  class SubCategory < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Categorical
    include OneclickRefernet::Confirmable
    include OneclickRefernet::RefernetServiceable
    include OneclickRefernet::CategoryTranslatable
    
    ### ASSOCIATIONS ###
    belongs_to :category
    has_many :sub_sub_categories, dependent: :destroy
    has_many :services, through: :sub_sub_categories
        
        
    ### CLASS METHODS ###
    
    # Downloads sub-categories for a given category, from ReferNET
    def self.fetch_by_category(category)
      refernet_service
      .get_sub_categories(category.name)
      .try(:map) do |sub_cat|
        name = sub_cat["Subcategory_Name"].try(:strip)
        next nil unless name.present?
        Rails.logger.info "Building new sub_category with name: #{name}"
        category.sub_categories.build(
          name: name, 
          refernet_category_id: sub_cat["Category_ID"],
          confirmed: false
        )
      end.compact
    end
    
  end
end
