module OneclickRefernet
  class Service < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Confirmable
    
    ### ATTRIBUTES ###
    serialize :details
    
    ### ASSOCIATIONS ###
    has_many :services_sub_sub_categories
    has_many :sub_sub_categories, through: :services_sub_sub_categories
    has_many :sub_categories, through: :sub_sub_categories
    has_many :categories, through: :sub_categories
    
    
    ### CLASS METHODS ###
    
    # Fetch services by sub-sub-category from ReferNET
    def self.fetch_by_sub_sub_category(sub_sub_cat)
      refernet_service
      .get_services_by_category_and_county(sub_sub_cat.name)
      .try(:map) do |svc|
        name = svc["Name_Agency"].try(:strip)
        next nil unless name.present?
        Rails.logger.info "Building new service with name: #{svc["Name_Agency"]}"
        sub_sub_cat.services.build(
          name: name,
          details: svc
        )
      end.compact

    end
    
  end
end
