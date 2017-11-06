module OneclickRefernet
	
	class TranslationService

		def set key, locale, value
			translation = OneclickRefernet::Translation.where(key: key, locale: locale.to_s).first_or_initialize
			translation.value = value
			translation.save 
		end	

		def get key, locale=:en
			OneclickRefernet::Translation.find_by(key: key, locale: locale.to_s).try(:value)
		end	
	end
end
