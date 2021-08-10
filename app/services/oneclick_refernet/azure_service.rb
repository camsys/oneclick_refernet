module OneclickRefernet
	
	class AzureService

  	require 'net/http'
		attr_accessor :api_key
    BASE_URL = "https://api.211.org/"
		DEFAULT_API_KEY = OneclickRefernet.api_token
		SUB_SUB_CATEGORY_IDENTIFIER = 'taxonomy_code'

		def initialize(api_key=DEFAULT_API_KEY)
			@api_key = api_key
		end

    def column_name_mappings
      {
          service_id_column_name: 'idService',
          location_id_column_name: 'idLocation'
          #service_site_id_column_name: 'idLocation',
      }
    end

		def labels
			[
					"Description",
          "Application Process",
          "Wait Time",
          "Fees",
          "Accreditations",
          "Schedule",
          "Language",
          "Eligibility",
          "Document",
          "Temporary Message"
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
    # Not Currently Used
		def search_keyword keyword, additional_params={}
			params = {
					keyword: keyword
			}.merge(additional_params)
			unpack(self.send(search_url("Search/Keyword", params)))
		end

		# Gets all top-level categories
    # Not Currently Used
		def get_categories
			unpack(self.send(search_url("Filters/Topics")))
		end
				
    # Get all categories and sub categories
    # Not Currently USed
    def get_azure_taxonomy
      unpack(self.send(search_url("Filters/TopicsSubtopics", topicOwner: 'AIRS-Default')))
    end
	
    #Get all organizations (with services)
    def get_all_organizations updated_after=nil 
      page_index=0
      results = []
      done = false
      while !done do 
        puts "Grabbing 500 Orgs"
	      orgs = get_paginated_organizations(updated_after, 500, page_index)
        page_index += 1 
        if orgs.nil?
          done = true
        else
          results += orgs 
        end
      end
      results 
    end

    # Get paginated list of organizations
    def get_paginated_organizations updated_after=nil, pageSize=500, pageIndex=0
      results = unpack(self.send(export_url(updated_after,pageSize,pageIndex)))
      results['organizations'] unless results == []
    end


    # Tool used to determine how many sub categories exist below a Category
    # Only used for debugging
    def get_max_depth cat, depth=1, name_chain=nil
      #Build up the Chain
      if name_chain.nil?
        name_chain = cat['name']
      else
        name_chain = "#{name_chain} > #{cat['name']}"
      end

      if cat["subtopics"] == nil 
        puts "This chain is #{depth} levels deep"
        puts name_chain
        puts '-----------------'
      else
        cat["subtopics"].each do |sub|
          get_max_depth(sub, depth + 1, name_chain)
        end
      end
    end

    def count_services
      orgs = get_all_organizations 
      service_count = 0
      service_location_count = 0
      puts "There are #{orgs.count} orgs."
      orgs.each do |org|
        services = org["services"]
        service_count += services.count 
        services.each do |svc|
          service_location_count += svc["serviceAtLocation"].count
        end
      end
      puts "There are #{service_count} services."
      puts "There are #{service_location_count} service locations."
    end



		# protected
		
		# Builds a ReferNET URL string
		def search_url(root, query_params={})
			"#{BASE_URL}search/api/v1/#{root}?#{query_params.to_query}"
		end

    #Export all the ORgs
    #TODO: Handle the params
    def export_url updated_after=nil, pageSize=100, pageIndex=0
      url = "#{BASE_URL}export/v1/api/Organizations?pageSize=#{pageSize}&pageIndex=#{pageIndex}"
      if updated_after
        url += "&updatedAfterUtc=#{updated_after.utc.iso8601(3)}"
      end
      return url 
    end
		

		## Send the Requests
		def send(url)
			Rails.logger.debug(url)
      puts url
			begin
				uri = URI.parse(url)
				request = Net::HTTP::Get.new(uri.request_uri)
				# Request headers
				request['Cache-Control'] = 'no-cache'
				request['Api-Key'] = @api_key
				response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
					http.request(request)
				end

				return response
			rescue Exception=>e
        puts e.to_s
			 	nil
			end
		end #send
		
		# Pulls JSON response out of ReferNET XML response and parses it
		def unpack(response)
			if response.code == '200'
				begin
					return JSON.parse(response.body) || []
				rescue JSON::ParserError
					return []
				end
			else
				return []
			end
		end
  
  end

end
