module OneclickRefernet
  class Service < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Confirmable
    include OneclickRefernet::RefernetServiceable

    ### SCOPES ###
    scope :within_X_meters, -> (lat,lng,meters) do 
      where("ST_Distance_Sphere(latlng, ST_MakePoint(#{lat},#{lng})) <= #{meters} * 1")
    end

    #Does the same thing as within_x_meters, but in a different way
    scope :within_XX_meters, -> (lat,lng,meters) do
      where("ST_DWithin(latlng::geography, ST_GeogFromText(TEXT 'POINT(#{lng} #{lat})')::geography, #{meters}, false)")
    end

    #Creates a bounding box centered on a point.
    scope :within_box, -> (lat, lng, meters) do 
      #where("latlng && ST_MakeEnvelope(min_lat,min_lng,max_lat,max_lng,SRID)")
      where("latlng && ST_MakeEnvelope(#{(lat.to_f||0) - meters*0.000008994},#{(lng.to_f||0) - meters*0.0000102259},#{(lat.to_f||0) + meters*0.000008994},#{(lng.to_f||0) + meters*0.000102259},4326)")
    end

    scope :closest, -> (lat, lng) do 
      order("ST_Distance(latlng, ST_GeomFromText(TEXT 'POINT(#{lng} #{lat})')::geography)")
    end

    
    
    ### ATTRIBUTES ###
    serialize :details
    
    # Before validating, set fields based on details hash
    before_validation :set_latlng, :set_names, :set_description, :set_refernet_ids
    
    
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
      .get_services_by_category_and_county(sub_sub_cat.name.titleize)
      .try(:uniq) { |svc| [ svc["Service_ID"], svc["Location_ID" ], svc["ServiceSite_ID"] ] } # Get uniq service by refernet ids 
      .try(:map) do |svc|
        service_id = svc["Service_ID"]
        location_id = svc["Location_ID"]
        servicesite_id = svc["ServiceSite_ID"]
        next nil unless service_id.present? && location_id.present? && servicesite_id.present?
        
        Rails.logger.info "Updating or building new service with name: #{svc['Name_Site']}"
        new_service = OneclickRefernet::Service.unconfirmed.find_or_initialize_by(
          refernet_service_id: service_id,
          refernet_location_id: location_id,
          refernet_servicesite_id: servicesite_id,
          confirmed: false
        )
        new_service.assign_attributes(details: svc)
        next new_service
      end.compact
    end
    
    # Saves all services. Useful for refreshing their attributes from the details hash
    def self.save_all
      self.all.each {|svc| svc.save}
    end
    
    ### INSTANCE METHODS ###

    # Get Details
    def get_details
      RefernetService.new.get_service_details(self.details['Location_ID'], self.details['ServiceSite_ID'], self.details['Service_ID'])
    end
    
    # Returns the service's name
    def to_s
      agency_name || site_name || "OneclickRefernet::Service #{id}"
    end
    
    ## Calculated Methods (for API)
      
    # Pulls lat out of point
    def lat
      latlng.try(:y)
    end

    # Pulls lng out of point    
    def lng
      latlng.try(:x)
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
    
    # RGeo point factory takes x (lng), y (lat)
    def point_from_latlng(lat, lng)
      rgeo_factory.point(lng, lat)
    end
    
    # Sets the latlng point from lat and lng in the details
    def set_latlng
      lat, lng = details["Latitude"].to_f, details["Longitude"].to_f * -1
      self.latlng = point_from_latlng(lat, lng) unless (lat.zero? || lng.zero?)
    end
    
    
    ## Attribute Helper Methods
    
    # Sets agency and site names from details, if not already set
    def set_names
      self.agency_name ||= details["Name_Agency"]
      self.site_name ||= details["Name_Site"]
    end
    
    # Sets the service description based on the Service Description label, if available and not already set
    def set_description
      self.description ||= details["Label_Service Description"] if details["Label_Service Description"]
    end
    
    # Set ReferNET Service_ID, Location_ID, and ServiceSite_ID
    def set_refernet_ids
      self.refernet_service_id ||= details["Service_ID"].try(:to_i)
      self.refernet_location_id ||= details["Location_ID"].try(:to_i)
      self.refernet_servicesite_id ||= details["ServiceSite_ID"].try(:to_i)
    end
    
    # Relevant labels contained in the details hash
    LABELS = [
      "Service Description",
      "Eligibility",
      "Intake Procedure",
      "Fees",
      "Program Service Hours",
      "Documents Required",
      "Payment Options",
      "Site Hours",
      "LANGUAGES SPOKEN",
      "TRAVEL INSTRUCTIONS",
      "Area Served"
    ]


    ## Translation Helper Methods
    
    # Builds a translation key for this service and the passed label
    def translation_key(label)
      label = label.to_s.parameterize.underscore # Make label a snake_case string
      "SERVICE_#{self['details']['Service_ID']}+#{self['details']['ServiceSite_ID']}_#{label}"
    end
    
    # Get translated label by label name and locale
    def translated_label(label, locale=I18n.default_locale)
      OneclickRefernet::TranslationService.new.get(translation_key(label), locale)
    end
    
    # Set translated label by label name and locale
    def set_translated_label(label, locale=I18n.default_locale, value)
      OneclickRefernet::TranslationService.new.set(translation_key(label), locale, value)
    end
    
    # Destroys all translations for the given label
    def destroy_label_translations(label)
      OneclickRefernet::TranslationService.new.destroy_all(translation_key(label))
    end
    
    # All translations associated with this service for a given label
    def translations(label)
      OneclickRefernet::Translation.where(key: translation_key(label))
    end
    
    # All translations of a given label with a non-empty value
    def present_translations(label)
      translations(label).where("value <> ''").where.not(value: nil)
    end
    
  end
end
