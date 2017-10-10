module OneclickRefernet
	
	class TranslationService

		def set key, locale, value

			translation = Translation.where(key: key, locale: locale.to_s).first_or_initialize
			translation.value = value
			translation.save 
			puts translation.ai 
		end	

		def get key, locale=:en
			Translation.find_by(key: key, locale: locale.to_s).try(:value)
		end	
	end
end