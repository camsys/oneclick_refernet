module OneclickRefernet
  class SubSubCategory < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Categorical
    include OneclickRefernet::Confirmable
    include OneclickRefernet::RefernetServiceable
    include OneclickRefernet::CategoryTranslatable
    
    ### ASSOCIATIONS ###
    belongs_to :sub_category
    has_one :category, through: :sub_category
    has_many :services_sub_sub_categories, dependent: :destroy
    has_many :services, through: :services_sub_sub_categories


    ### CLASS METHODS ###
    
    # Fetch sub-sub-categories by sub-category from ReferNET
    def self.fetch_by_sub_category(sub_category)
      refernet_service
      .get_sub_sub_categories(sub_category.refernet_category_id)
      .try(:map) do |sub_sub_cat|
        name = sub_sub_cat["Name"]
        next nil unless name.present?
        Rails.logger.debug "Building new sub_sub_category with name: #{name}"
        sub_category.sub_sub_categories.build(
          name: name,
          code: name.to_s.strip.parameterize.underscore, # Convert name to a snake case code string,
          confirmed: false
        )
      end.compact

    end

  end
end
