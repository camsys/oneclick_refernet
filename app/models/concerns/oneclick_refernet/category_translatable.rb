module OneclickRefernet
  module CategoryTranslatable
    extend ActiveSupport::Concern

    def translated_name locale=I18n.default_locale
      OneclickRefernet::TranslationService.new.get(self.code, locale)
    end

    def set_translated_name locale=I18n.default_locale, value 
      OneclickRefernet::TranslationService.new.set(self.code, locale, value)
    end
    
    # Returns the translation of the passed locale
    def translation(locale=I18n.default_locale)
      translations.find_by(locale: locale)
    end
    
    # Returns all translations for the object's name
    def translations
      OneclickRefernet::Translation.where(key: self.code)
    end
    
    # Returns all translations that have a non-empty string for the translation
    def present_translations
      translations.where.not(value: nil).where("value <> ''")
    end
    

  end
end
