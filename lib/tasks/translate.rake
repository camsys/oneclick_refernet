namespace :oneclick_refernet do
  namespace :translate do

    desc "Translate All"
    task all: :environment do
      Rake::Task["oneclick_refernet:translate:categories"].invoke
      Rake::Task["oneclick_refernet:translate:services"].invoke
    end
    
    desc "Translate Categories"
    task categories: :environment do 
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
              ### Replace THIS with GOOGLE 
              translated = (locale == :en) ? cat.name : locale.to_s + cat.name.to_s
              ########################################
              cat.set_translated_name(locale, translated)
            end #I18n
            new_translations += 1
          end #IF
        end #cats.each
      end #Categories
      
      puts "#{new_translations} new Category Translations"

    end#Task

    desc "Translate Services"
    task services: :environment do 
      services_translated = 0
      OneclickRefernet::Service.all.each do |service|
        new_description = service['details']["Label_Service Description"]
        old_description = service.translated_description
        
        if old_description == new_description
          next
        else
          puts "------------------Translating SERVICE_#{service['details']['Service_ID']}+#{service['details']['ServiceSite_ID']}_description ------------------"
          I18n.available_locales.each do |locale|

            ### Replace THIS with GOOGLE 
            translated = (locale == :en) ? new_description : locale.to_s + new_description.to_s
            ########################################
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
  #"description":  service['details']["Label_Service Description"] || "#{service['details']['Note1']} #{service['details']['Note2']}",
end