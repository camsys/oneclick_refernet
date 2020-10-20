module OneclickRefernet
  class Service < ApplicationRecord
    
    ### INCLUDES ###
    include OneclickRefernet::Confirmable
    include OneclickRefernet::RefernetServiceable

    ### SCOPES ###

    # Finds all services within X meters
    scope :within_x_meters, -> (lat, lng, meters) do
      where("ST_DWithin(latlng::geography, ST_GeogFromText(TEXT 'POINT(#{lng} #{lat})')::geography, #{meters}, false)")
    end

    # Orders services by distance
    scope :closest, -> (lat, lng) do 
      order("ST_Distance(latlng, ST_GeomFromText(TEXT 'POINT(#{lng} #{lat})')::geography)")
    end
    
    ### ATTRIBUTES ###
    serialize :details
    serialize :location_details
    
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
    # Used for Referent: Not used for Azure
    def self.fetch_by_sub_sub_category(sub_sub_cat)
      refernet_service
      .get_services_by_category_and_county(sub_sub_cat.send(refernet_service.class::SUB_SUB_CATEGORY_IDENTIFIER))
      .try(:uniq) { |svc| [ svc[refernet_service.column_name_mappings[:service_id_column_name]], svc[refernet_service.column_name_mappings[:location_id_column_name]] ] } # Get uniq service by refernet ids
      .try(:map) do |svc|
        service_id = svc[refernet_service.column_name_mappings[:service_id_column_name]]
        location_id = svc[refernet_service.column_name_mappings[:location_id_column_name]]
        next nil unless service_id.present? && location_id.present?
        
        Rails.logger.debug "Updating or building new service with name: #{svc[refernet_service.column_name_mappings[:site_name_column_name]]}"
        new_service = OneclickRefernet::Service.unconfirmed.find_or_initialize_by(
          refernet_service_id: service_id,
          refernet_location_id: location_id,
          confirmed: false
        )
        new_service.assign_attributes(details: svc)
        next new_service
      end.compact
    end

    # Fetch all the Azure Services, Assign them to all the relevant subsubcategories (taxonomies)
    # Services with multiple locations are treated as separate services
    def self.create_from_azure updated_after=nil 
      tmp_orgs = [] 
      refernet_service.get_all_organizations(updated_after).each do |org|
        tmp_orgs << org
        org["services"].each do |svc|
          service_id = svc[refernet_service.column_name_mappings[:service_id_column_name]]
          svc["serviceAtLocation"].each do |loc|
            location_id = loc["idLocation"]
            location_details = org["locations"].select {|location| location["idLocation"] == location_id }.uniq.first
            new_service = OneclickRefernet::Service.unconfirmed.find_or_initialize_by(
                refernet_service_id: service_id,
                refernet_location_id: location_id,
                confirmed: false
            )

            org_name = org["name"]
            service_name = svc["name"]
            location_name = location_details.try(:[], "name") || "N/A"

            new_service.agency_name = "#{org_name} #{service_name}"
            new_service.site_name = location_name 

            new_service.assign_attributes(details: svc, location_details: location_details)
            new_service.save! 

            #Assign the services to the taxonomies
            svc["taxonomy"].each do |taxonomy|
              term = taxonomy["term"]
              sub_sub_category = OneclickRefernet::SubSubCategory.find_by(name: term)
              sub_sub_category.services << new_service if sub_sub_category
            end

          end #Locations
        end #Services
      end #Orgs
      tmp_orgs
    end

    # Saves all services. Useful for refreshing their attributes from the details hash
    def self.save_all
      self.all.each {|svc| svc.save}
    end
    
    ### INSTANCE METHODS ###

    # Get Details
    def get_details
      self.class.refernet_service.get_service_details(self.details[self.class.refernet_service.column_name_mappings[:location_id_column_name]], self.details[self.class.refernet_service.column_name_mappings[:service_id_column_name]], self.details[self.class.refernet_service.column_name_mappings[:service_site_id_column_name]])
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
      if ENV['REFERNET_SERVICE_CLASS'] == 'RefernetService'
        details.values_at(*[self.class.refernet_service.column_name_mappings[:address1_column_name],self.class.refernet_service.column_name_mappings[:address2_column_name],self.class.refernet_service.column_name_mappings[:city_column_name],self.class.refernet_service.column_name_mappings[:state_column_name]]).compact.join(', ') + " #{details[self.class.refernet_service.column_name_mappings[:zipcode_column_name]]}"      
      elsif true # DEREK ENV['REFERNET_SERVICE_CLASS'] == 'AzureService'
        addr = location_details['address'].find{ |address| address['type'] == 'physical'} if location_details['address']
        "#{addr['address_1']}#{' ' + addr['address_2'] if addr['address_2']}, #{addr['city']}"
      end
    end

  # Returns whatever phone number can be found
    def phone
      if ENV['REFERNET_SERVICE_CLASS'] == 'RefernetService'
        details["Number_Phone1"] ||
        details["Number_Phone2"] ||
        details["Number_Phone3"]  
      else true #DEREK
        details["phone"].try(:first).try(:[], "number")
      end        
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
      if ENV['REFERNET_SERVICE_CLASS'] == 'RefernetService'
        lat, lng = details[self.class.refernet_service.column_name_mappings[:latitude_column_name]].to_f, details[self.class.refernet_service.column_name_mappings[:longitude_column_name]].to_f.abs * -1
      elsif true # DEREK ENV['REFERNET_SERVICE_CLASS'] == 'AzureService'
        lat, lng = location_details.try(:[], "latitude").to_f, location_details.try(:[], "longitude").to_f 
      end
      self.latlng = point_from_latlng(lat, lng) unless (lat.zero? || lng.zero?)
    end

    ## Attribute Helper Methods
    # Sets agency and site names from details, if not already set
    def set_names
      if ENV['REFERNET_SERVICE_CLASS'] == 'RefernetService'
        self.agency_name ||= details[self.class.refernet_service.column_name_mappings[:agency_name_column_name]]
        self.site_name ||= details[self.class.refernet_service.column_name_mappings[:site_name_column_name]]
      end 
      #AZURE Service NAMES ARE SET WHEN THE SERVICE IS CREATED
    end 
    
    # Sets the service description based on the Service Description label, if available and not already set
    def set_description
      descrip_column_name = self.class.refernet_service.column_name_mappings[:description_column_name]
      self.description ||= details[descrip_column_name] if details[descrip_column_name]
    end
    
    # Set ReferNET Service_ID, Location_ID, and ServiceSite_ID
    def set_refernet_ids
      self.refernet_service_id ||= details[self.class.refernet_service.column_name_mappings[:service_id_column_name]]
      self.refernet_location_id ||= details[self.class.refernet_service.column_name_mappings[:location_id_column_name]]
      self.refernet_servicesite_id ||= details[self.class.refernet_service.column_name_mappings[:service_site_id_column_name]]
    end
    
    ## Translation Helper Methods
    
    # Builds a translation key for this service and the passed label
    def translation_key(label)
      label = label.to_s.parameterize.underscore # Make label a snake_case string
      "SERVICE_#{details[self.class.refernet_service.column_name_mappings[:service_id_column_name]]}+#{details[self.class.refernet_service.column_name_mappings[:service_site_id_column_name]]}_#{label}"
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
