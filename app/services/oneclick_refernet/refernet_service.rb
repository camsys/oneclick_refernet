module OneclickRefernet
	
	class RefernetService

  	require 'net/http'
		attr_accessor :api_key
	  BASE_URL = "http://www.referweb.net/mws/service.asmx/"
		DEFAULT_API_KEY = OneclickRefernet.api_token

		def initialize(api_key=DEFAULT_API_KEY)
			@api_key = api_key
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
			unpack(self.send(refernet_url("Category")))
		end
				
		# Gets all sub-categories for a given category name
		def get_sub_categories(category_name)
			unpack(self.send(refernet_url("Sub_Category", category_name: category_name)))
		end
	
		# Gets all sub-sub-categories for a given sub-category name
		def get_sub_sub_categories(sub_category_id)
			unpack(self.send(refernet_url("SubCat_Links", category_id: sub_category_id)))
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
		def get_service_details(loc_id, service_site_id, service_id)
			params = {
				locid: loc_id,
				servicesiteid: service_site_id,
				serviceid: service_id
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
	  	  Rails.logger.info(url)
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
