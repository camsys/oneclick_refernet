namespace :oneclick_refernet do
  namespace :translate do

    desc "Translate All"
    task :all, [:google_api_key] => [
      :categories,
      :services
    ]
    
    desc "Translate Categories"
    task :categories, [:google_api_key] =>  [:environment] do |t,args| 

      if args[:google_api_key]
        puts 'Using Google Translate'
        gt = OneclickRefernet::GoogleTranslate.new(args[:google_api_key])
      else
        puts 'Using Fake Translate'
      end

      new_translations = 0
      ['Category', 'SubCategory', 'SubSubCategory'].each do |model|
        
        # Get the right objects
        case model
        when 'Category'
          cats = OneclickRefernet::Category.all
        when 'SubCategory'
          cats = OneclickRefernet::SubCategory.all
        when 'SubSubCategory'
          cats = OneclickRefernet::SubSubCategory.all
        end
        
        # For each category, look through its translations, and translate any 
        # missing ones based on the available locales
        cats.each do |cat|
          
          puts "------------------Translating #{cat.class.name} #{cat.name} ------------------"
          locales_translated = cat.present_translations.pluck(:locale).map(&:to_sym)
          
          # Only translate available locales with missing translations
          (I18n.available_locales - locales_translated).each do |locale|
            
            if(locale == :en) # If locale is English, simply titleize the code
              translated = cat.name
            else # Otherwise, translate the titleized code into the given locale
              if(args[:google_api_key]) # GOOGLE Translate
                translated = gt.translate(cat.name, locale.to_s, :en)
              else # Fake Translate
                translated = "#{locale}_#{cat.code}"
              end
            end
      
            # Set the translation and increment the counter
            cat.set_translated_name(locale, translated)
            new_translations += 1
            
          end # locales.each
        end # cats.each

      end #Categories
      
      puts "#{new_translations} new Category Translations"

    end#Task

    desc "Translate Services"
    task :services, [:google_api_key] =>  [:environment] do |t,args| 

      if args[:google_api_key]
        puts 'Using Google Translate'
        gt = OneclickRefernet::GoogleTranslate.new(args[:google_api_key])
      else
        puts 'Using Fake Translate'
      end
 
      services_translated = 0
      OneclickRefernet::Service.all.each do |service|
        puts "------------------Translating SERVICE_#{service['details']['Service_ID']}+#{service['details']['ServiceSite_ID']}_description ------------------"
        
        # Check if the description field has changed
        new_description = service['details']["Label_Service Description"]
        old_description = service.translated_description
        
        # If the description has changed, treat all locales as needing translation
        if old_description != new_description
          locales_translated = []
        else # Otherwise, check to see which locales are missing a translation
          locales_translated = service.present_translations.pluck(:locale).map(&:to_sym)
        end
        
        # Go through all the locales that need translating, and translate the description for that locale
        (I18n.available_locales - locales_translated).each do |locale|
          if(locale == :en) # If locale is English, simply copy over the description
            translated = new_description
          else # Otherwise, translate the titleized code into the given locale
            if(args[:google_api_key]) # GOOGLE Translate
              translated = gt.translate(new_description, locale.to_s, :en)
            else # Fake Translate
              translated = "#{locale}_#{new_description}"
            end
          end
      
          service.set_translated_description(locale, translated)
        end # locales.each
        
        # Increment the services translated count
        services_translated += 1  
        
      end # services.each
      puts "Services with new translations: #{services_translated}"
      puts "Services skipped: #{OneclickRefernet::Service.count - services_translated}"
    end
  end

end
