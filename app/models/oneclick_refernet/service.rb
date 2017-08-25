module OneclickRefernet
  class Service < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Confirmable
    include OneclickRefernet::RefernetServiceable
    require 'street_address'
    
    ### ATTRIBUTES ###
    serialize :details
    before_save :set_latlng # Before saving, set latlng value based on details hash
    before_validation :set_names # Set names from details if not set already
    
    ### ASSOCIATIONS ###
    has_many :services_sub_sub_categories, dependent: :destroy
    has_many :sub_sub_categories, through: :services_sub_sub_categories
    has_many :sub_categories, through: :sub_sub_categories
    has_many :categories, through: :sub_categories
    
    ### VALIDATIONS ###
    validates :agency_name, presence: true
    validates :site_name, presence: true
    
    ### CLASS METHODS ###
    
    # Fetch services by sub-sub-category from ReferNET
    def self.fetch_by_sub_sub_category(sub_sub_cat)
      refernet_service
      .get_services_by_category_and_county(sub_sub_cat.name)
      .try(:map) do |svc_hash|
        agency_name = svc_hash["Name_Agency"].try(:strip)
        site_name = svc_hash["Name_Site"].try(:strip)
        next nil unless agency_name.present? && site_name.present?
        
        Rails.logger.info "Updating or building new service with name: agency_name}"
        new_service = OneclickRefernet::Service.unconfirmed.find_or_initialize_by(
          agency_name: agency_name,
          site_name: site_name,
          confirmed: false
        )
        new_service.assign_attributes(details: svc_hash)
        next new_service
      end.compact

    end
    
    
    ### INSTANCE METHODS ###
    
    
    ## Calculated Methods (for API)
      
    # Pulls lat out of point
    def lat
      latlng.x
    end

    # Pulls lng out of point    
    def lng
      latlng.y
    end
    
    # Constructs a formatted address
    def address
      details.values_at(*%w(Address1 Address2 City State)).compact.join(', ') + 
      " #{details['ZipCode']}"
    end

    def street_number
      StreetAddress::US.parse(address).number
    end

    def route
      "#{StreetAddress::US.parse(address).street} #{StreetAddress::US.parse(address).street_type}"
    end
    
    ## Geometry Helper Methods
    
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
    
    # Sets agency and site names from details, if not already set
    def set_names
      self.agency_name ||= details["Name_Agency"]
      self.site_name ||= details["Name_Site"]
    end
    
    
  end
end
