module OneclickRefernet
	
	class AzureService

  	require 'net/http'
		attr_accessor :api_key
	  BASE_URL = "https://api-dev.211.technology/search/api/"
		DEFAULT_API_KEY = OneclickRefernet.api_token
		SUB_SUB_CATEGORY_IDENTIFIER = 'taxonomy_code'

		def initialize(api_key=DEFAULT_API_KEY)
			@api_key = api_key
		end

		# mapping to parse response from returned API data
		# different services will call similar data by different names
		def column_name_mappings
			{
					service_id_column_name: 'idService',
					location_id_column_name: 'idLocation',
					service_site_id_column_name: 'idServiceAtLocation',
					site_name_column_name: 'nameLocation',
					agency_name_column_name: 'nameOrganization',
					address1_column_name: 'address_1',
					address2_column_name: 'address_2',
					city_column_name: 'city',
					state_column_name: 'state_province',
					zipcode_column_name: 'zipcode',
					latitude_column_name: 'latitudeLocation',
					longitude_column_name: 'longitudeLocation',
					description_column_name: 'descriptionService',
					phone_column_name: 'phone_number',
			}
		end

		def labels
			[
					"Service Description",
					"Eligibility",
					"Intake Procedure",
					"Fees",
					"Program Service Hours", #
					"Documents Required",
					"Payment Options", #
					"Site Hours", #
					"LANGUAGES SPOKEN",
					"TRAVEL INSTRUCTIONS",
					"Accessibility"
			]
		end

		def service_id_column_name
			'idService'
		end

		def location_id_column_name
			'idLocation'
		end

		# Keyword Search
		# Returns an array of Hashes of ReferNET Services
		def search_keyword keyword, additional_params={}
			params = {
					keyword: keyword
			}.merge(additional_params)
			unpack(self.send(refernet_url("Search/Keyword", params)))
		end

		# Gets all top-level categories
		def get_categories
			unpack(self.send(refernet_url("Filters/Topics")))
		end
				
		# Gets all sub-categories for a given category name
		def get_sub_categories(category_name)
			results = unpack(self.send(refernet_url("Filters/TopicsSubtopics", topicOwner: 'AIRS-Default')))
      results.find{|row| row['name'] == category_name}['subtopics'].map{ |sub_cat| [sub_cat["name"], sub_cat["taxonomyTerm"]] }
		end

		def get_taxonomy_code(sub_category_name)
			results = unpack(self.send(refernet_url("Filters/TopicsSubtopics", topicOwner: 'AIRS-Default')))

			# iterate through the hierarchy to just get sub sub categories
			results = results.map{|row| row['subtopics']}.flatten.map{|row| row['subtopics']}.flatten.map{|row| row.present? ? row['subtopics'] : nil}.flatten.compact


			result = results.find{|subtopic| subtopic.present? && subtopic['name'] == sub_category_name} || {}

			puts "Can't find sub sub category for #{sub_category_name}" unless result['taxonomyTerm']
			return result['taxonomyTerm']
		end
	
		# Gets all sub-sub-categories for a given sub-category
		def get_sub_sub_categories(sub_category_name)
			results = unpack(self.send(refernet_url("Filters/TopicsSubtopics", topicOwner: 'AIRS-Default')))
			results.map{|row| row['subtopics']}.flatten.select{|subtopic| subtopic['name'] == sub_category_name}['subtopics']
		end
		
		# Gets all services for a given sub-sub-category and county
		def get_services_by_category_and_county(taxonomy_code)
			if taxonomy_code
				results = unpack(self.send(refernet_url("Search/Guided", {taxonomyCode: taxonomy_code})))
				results = results['results'].map{|row| row['document']} unless results == []
				return results
			else
				[]
			end
		end

    # Add details for each Service
    # The labels are found in a separate call
		def get_service_details(loc_id, service_id, service_site_id)
			unpack(self.send(refernet_url("ServiceAtLocation", {idServiceAtLocation: service_site_id})))[0]
		end

		# protected
		
		# Builds a ReferNET URL string
		def refernet_url(root, query_params={})
			"#{BASE_URL}#{root}?#{query_params.to_query}"
		end
		

		## Send the Requests
		def send(url)
			Rails.logger.debug(url)
			# begin
				uri = URI.parse(url)
				request = Net::HTTP::Get.new(uri.request_uri)
				# Request headers
				request['Cache-Control'] = 'no-cache'
				request['Ocp-Apim-Subscription-Key'] = @api_key
				response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
					http.request(request)
				end

				return response
			# rescue Exception=>e
			# 	nil
			# end
		end #send
		
		# Pulls JSON response out of ReferNET XML response and parses it
		def unpack(response)
			if response.code == '200'
				# begin
					return JSON.parse(response.body) || []
				# rescue JSON::ParserError
				# 	return []
				# end
			else
				return []
			end
		end
  
  end

end
