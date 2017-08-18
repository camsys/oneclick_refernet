module OneclickRefernet
  class Service < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Confirmable
    
    ### ATTRIBUTES ###
    serialize :details
    before_save :set_latlng # Before saving, set latlng value based on details hash
    
    ### ASSOCIATIONS ###
    has_many :services_sub_sub_categories, dependent: :destroy
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
        Rails.logger.info "Updating or building new service with name: #{svc["Name_Agency"]}"
        new_service = OneclickRefernet::Service.unconfirmed.find_or_initialize_by(
          name: name,
          confirmed: false
        )
        new_service.assign_attributes(details: svc)
        next new_service
      end.compact

    end

    
    
    ### INSTANCE METHODS ###
    
    # Build an RGeo spatial factory
    def rgeo_factory
      RGeo::Geos::CAPIFactory.new(:srid => 4326)
    end
    
    def point_from_latlng(lat, lng)
      rgeo_factory.point(lat, lng)
    end
    
    # Sets the latlng point from lat and lng in the details
    def set_latlng
      lat, lng = details["Latitude"].to_f, details["Longitude"].to_f * -1
      self.latlng = rgeo_factory.point(lat, lng) unless (lat.zero? || lng.zero?)
    end
    
    
  end
end
