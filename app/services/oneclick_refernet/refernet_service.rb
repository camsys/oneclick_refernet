module OneclickRefernet
	
	class RefernetService

  	require 'net/http'
		attr_accessor :api_key
	  BASE_URL = "http://www.referweb.net/mws/service.asmx/"
		DEFAULT_API_KEY = OneclickRefernet.api_token
		SUB_SUB_CATEGORY_IDENTIFIER = 'name'

		def initialize(api_key=DEFAULT_API_KEY)
			@api_key = api_key
		end

		# mapping to parse response from returned API data
		# different services will call similar data by different names
		def column_name_mappings
			{
					service_id_column_name: 'Service_ID',
					location_id_column_name: 'Location_ID',
					service_site_id_column_name: 'ServiceSite_ID',
					site_name_column_name: 'Name_Site',
					agency_name_column_name: 'Name_Agency',
					address1_column_name: 'Address1',
					address2_column_name: 'Address2',
					city_column_name: 'City',
					state_column_name: 'State',
					zipcode_column_name: 'ZipCode',
					latitude_column_name: 'Latitude',
					longitude_column_name: 'Longitude',
					description_column_name: 'Label_Service Description',
					phone_column_name: "Number_Phone"
			}
		end

		# Keyword Search
		# Returns an array of Hashes of ReferNET Services
		def search_keyword keyword
			params = {
				'ro' => '', 
				'keyw' => keyword, 
				'zipcode' => ''
			}
			unpack(self.send(refernet_url("Keyword_Name_Search", params)))
		end

		# Gets all top-level categories (array of hashes)
		def get_categories
			unpack(self.send(refernet_url("Category"))).map{ |cat| cat["Category_Name"] }
		end
				
		# Gets all sub-categories for a given category name
		def get_sub_categories(category_name)
			unpack(self.send(refernet_url("Sub_Category", category_name: category_name))).map{ |sub_cat| [sub_cat["Subcategory_Name"], sub_cat["Category_ID"]] }
		end
	
		# Gets all sub-sub-categories for a given sub-category name
		def get_sub_sub_categories(sub_category_id)
			unpack(self.send(refernet_url("SubCat_Links", category_id: sub_category_id))).map{ |cat| cat["Name"] }
		end
		
		# Gets all services for a given sub-sub-category and county
		def get_services_by_category_and_county(sub_sub_category_name, county_code=123)
			params = {
				zip: '',
				searchterm: sub_sub_category_name,
				county_id: county_code
			}
			unpack(self.send(refernet_url("MatchList", params)))
		end

    # Add details for each Service
    # The labels are found in a separate call
		def get_service_details(loc_id, service_id, service_site_id)
			params = {
				locid: loc_id,
				serviceid: service_id,
				servicesiteid: service_site_id
			}
			unpack(self.send(refernet_url("DetailPage", params)))
		end

		# protected
		
		# Builds a ReferNET URL string
		def refernet_url(root, query_params={})
			query_params = { api_key: @api_key, 'deviceId' => '' }.merge(query_params)
			"#{BASE_URL}#{root}?#{query_params.to_query}"
		end
		

		## Send the Requests
	    def send(url)
	  	  Rails.logger.debug(url)
	      begin
	        uri = URI.parse(url)
	        req = Net::HTTP::Get.new(uri)
	        http = Net::HTTP.new(uri.host, uri.port)
	        http.use_ssl = false
	        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	        http.start {|http| http.request(req)}
	      rescue Exception=>e
	        nil
	      end
	    end #send
		
		# Pulls JSON response out of ReferNET XML response and parses it
		def unpack(response)
			if response.code == '200'
				begin
					return JSON.parse(Hash.from_xml(response.body)["anyType"]) || []
				rescue JSON::ParserError
					return []
				end
			else
				return []
			end
		end
  
  end #RefernetService

end #RefernetServices
