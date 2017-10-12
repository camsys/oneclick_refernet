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

        # Make sure translations exist for those objects
        cats.each do |cat|
          if cat.translated_name(:en) == cat.name
            next
          else
            puts "------------------Translating #{cat.name}------------------"
            I18n.available_locales.each do |locale|

              if args[:google_api_key] ### GOOGLE Translate
                translated = (locale == :en) ? cat.name : gt.translate(cat.name, locale.to_s, :en)
              else ### Fake Translate  
                translated = (locale == :en) ? cat.name : locale.to_s + cat.name.to_s
              end

              cat.set_translated_name(locale, translated)
            end #I18n
            new_translations += 1
          end #IF
        end #cats.each
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
        new_description = service['details']["Label_Service Description"]
        old_description = service.translated_description
        
        if old_description == new_description
          next
        else
          puts "------------------Translating SERVICE_#{service['details']['Service_ID']}+#{service['details']['ServiceSite_ID']}_description ------------------"
          I18n.available_locales.each do |locale|

            if args[:google_api_key] ### GOOGLE Translate
              translated = (locale == :en) ? new_description : gt.translate(new_description, locale.to_s, :en)
            else ### Fake Translate  
              translated = (locale == :en) ? new_description : locale.to_s + new_description.to_s
            end

            service.set_translated_description(locale, translated)
          end
          services_translated += 1  
          puts new_description
        end
      end
      puts "Services with new translations: #{services_translated}"
      puts "Services skipped: #{OneclickRefernet::Service.count - services_translated}"
    end
  end

end