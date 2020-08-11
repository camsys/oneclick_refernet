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
        puts
        puts "------------------Translating SERVICE #{service.id}: #{service.site_name} ------------------"
        
        # Translate each relevant label
        OneclickRefernet::Service.refernet_service.labels.each do |label|
          
          new_value = service['details']["Label_#{label.parameterize.underscore}"]
          
          # If the value is nil, delete translations for this label
          if new_value.nil?
            puts "No value for #{service.translation_key(label)}; not translating"
            service.destroy_label_translations(label)
            next
          end
          
          puts "Translating #{service.translation_key(label)}"
          
          # Check if the description field has changed
          old_value = service.translated_label(label, :en)
          
          # If the label value has changed, treat all locales as needing translation
          if new_value != old_value
            locales_translated = []
          else # Otherwise, check to see which locales are missing a translation
            locales_translated = service.present_translations(label).pluck(:locale).map(&:to_sym)
          end
          
          # Go through all the locales that need translating, and translate the label for that locale
          (I18n.available_locales - locales_translated).each do |locale|
            if(locale == :en) # If locale is English, simply copy over the description
              translated = new_value
            else # Otherwise, translate the titleized code into the given locale
              if(args[:google_api_key]) # GOOGLE Translate
                translated = gt.translate(new_value, locale.to_s, :en)
              else # Fake Translate
                translated = "#{locale}_#{new_value}"
              end
            end
        
            service.set_translated_label(label, locale, translated)
          end # locales.each
                
                         
        end
        
        # Increment the services translated count
        services_translated += 1  
        
      end # services.each
      puts "Services with new translations: #{services_translated}"
      puts "Services skipped: #{OneclickRefernet::Service.count - services_translated}"
    end
  end

end
