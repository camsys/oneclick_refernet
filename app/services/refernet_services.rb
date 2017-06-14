module RefernetServices
	
	class RefernetService

  	require 'net/http'
		attr_accessor :api_key
	  BASE_URL = "http://www.referweb.net/mws/service.asmx/"

		def initialize(api_key)
			@api_key = api_key
		end

		# Keyword Search
		# Returns an array of Hashes of ReferNET Services
		def search_keyword keyword
			response = self.send("#{BASE_URL}Keyword_Name_Search?api_key=#{@api_key}&ro=&keyw=#{keyword}&zipcode=&deviceId=0")
      if response.code == '200'
        return JSON.parse(Hash.from_xml(response.body)["anyType"])
      else
      	return []
      end
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
  
  end #RefernetService

end #RefernetServices