module OneclickRefernet
  module CategoryTranslatable
    extend ActiveSupport::Concern

    def translated_name locale=:en
      OneclickRefernet::TranslationService.new.get(self.name, locale)
    end

    def set_translated_name locale=:en, value 
      OneclickRefernet::TranslationService.new.set(self.name, locale, value)
    end

  end
end