module OneclickRefernet
  class Service < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Confirmable
    include OneclickRefernet::RefernetServiceable

    ### SCOPES ###
    scope :within_X_meters, -> (lat,lng,meters) do
      where("ST_DWithin(latlng::geography, ST_GeomFromText('POINT(#{lat} #{lng})', 4326)::geography, #{meters})")
    end
    
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

    # Get Details
    def get_details
      RefernetService.new.get_service_details(self.details['Location_ID'], self.details['ServiceSite_ID'], self.details['Service_ID'])
    end    
    
    ### INSTANCE METHODS ###
    
    # Returns the service's name
    def to_s
      agency_name || site_name || "OneclickRefernet::Service #{id}"
    end
    
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


    ## Translation Helper Methods
    
    # Set Description
    def translated_description locale=:en
      OneclickRefernet::TranslationService.new.get("SERVICE_#{self['details']['Service_ID']}+#{self['details']['ServiceSite_ID']}_description", locale)
    end
    
    # Get Description
    def set_translated_description locale=:en, value 
      OneclickRefernet::TranslationService.new.set("SERVICE_#{self['details']['Service_ID']}+#{self['details']['ServiceSite_ID']}_description", locale, value)
    end
    
    
  end
end
