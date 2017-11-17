module OneclickRefernet
	
	class TranslationService

		def set key, locale, value
			translation = OneclickRefernet::Translation.where(key: key, locale: locale.to_s).first_or_initialize
			translation.value = value
			translation.save 
		end

		def get key, locale=I18n.default_locale
			OneclickRefernet::Translation.find_by(key: key, locale: locale.to_s).try(:value)
		end
		
		# Destroys translation for the given key and locale
		def destroy(key, locale=I18n.default_locale)
			OneclickRefernet::Translation.find_by(key: key, locale: locale.to_s).destroy
		end
		
		# Destroys all translations for a given key
		def destroy_all(key)
			OneclickRefernet::Translation.where(key: key).destroy_all
		end
			
	end
end
