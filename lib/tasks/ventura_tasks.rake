namespace :ventura do
  
  require 'tasks/helpers/refernet_task_helpers'
  include RefernetTaskHelpers

  desc "Prepares for Rake Tasks" 
  task prepare_environment: :environment do
    
    # Set the logger to log to the console
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = 1
    
    # set shorthand for engine
    OCR = OneclickRefernet

  end

  desc "Load database if it's more than a week old"
  task :load_database_on_sunday, [:google_api_key] =>  [:prepare_environment] do |t,args|
    # Runs load_database only if it's Sunday
    if DateTime.now.wday == 0
      Rails.logger.info "It's Sunday! Running the load database task..."
      Rake::Task["oneclick_refernet:load:database"].invoke(args[:google_api_key])
    else
      Rails.logger.info "Not running the load database task because it isn't Sunday."
    end
  end

  desc "Alias for load:database task"
  task :load_database, [:google_api_key] => ["load:database"]
  
  ### TASKS FOR LOADING REFERNET DATA ###
  namespace :load do
    
    desc "Prepare to Load ReferNET Database"
    task prepare: :prepare_environment do
      @errors ||= []
      @tables = [OCR::Category, OCR::SubCategory, OCR::SubSubCategory, OCR::Service]
    end    
    
    desc "Load, Confirm, and Translate all ReferNET Tables"
    task :database, [:google_api_key] => [:prepare] do |t,args|

      Rails.logger.info "*** LOADING REFERNET CATEGORIES AND SERVICES ***"

      ### LOAD ALL DATABASE TABLES ###
      Rake::Task["ventura:load:categories"].invoke
      Rake::Task["ventura:load:sub_categories"].invoke
      Rake::Task["ventura:load:sub_sub_categories"].invoke(args[:google_api_key] || '')
      Rake::Task["oneclick_refernet:load:services"].invoke
      
      ### CONFIRM CHANGES ###
      Rake::Task["oneclick_refernet:load:confirm"].invoke
      
      ### LOAD SERVICE DETAILS ###
      Rake::Task["oneclick_refernet:load:service_details"].invoke

      ### TRANSLATE ALL TABLES ###
      Rake::Task["oneclick_refernet:translate:all"].invoke(args[:google_api_key])
      
      Rails.logger.info "*** COMPLETED LOADING REFERNET DATABASE ***"
    end
  
    desc "Load Categories from ReferNET"
    task categories: :prepare do
      
      begin
        new_categories = [
          'HOUSING & HOMELESS SERVICES',
          'INCOME & EXPENSES',
          'FOOD',
          'CRISIS SERVICES',
          'HEALTH CARE',
          'MENTAL HEALTH',
          'SUBSTANCE USE DISORDER',
          'CHILDREN & FAMILY',
          'YOUTH',
          'SENIORS',
          'EDUCATION',
          'LEGAL ASSISTANCE'
        ].map do |category_name|
          OCR::Category.setup_category(category_name.downcase.titleize)
        end.compact

        @errors += save_and_log_errors(new_categories)
        raise "ERROR LOADING REFERNET CATEGORIES" unless @errors.empty?

        Rails.logger.info "*** Successfully Loaded #{OCR::Category.unconfirmed.count} Categories ***"

      rescue => e
        catch_refernet_load_errors(e, OCR::Category, @errors)
      end

    end
    
    desc "Load SubCategories from ReferNET"
    task sub_categories: :prepare do
      begin

        cat_count = 0
        total_cat_count = OCR::Category.unconfirmed.count
        OCR::SubCategory.destroy_unconfirmed # First, clear out all unconfirmed subcategories before loading new ones

        {
            'HOUSING & HOMELESS SERVICES' => [
                'Housing Expense Assistance',
                'Emergency Housing & Services for Homeless Individuals & Families',
                'Affordable Housing Options',
                'Landlord/Tenant Assistance'
            ],
            'INCOME & EXPENSES' => [
                'Employment',
                'Money Management',
                'Public Assistance & Benefits',
                'Utility Assistance',
                'Housing',
                'Personal/Household Items & Other Expenses'
            ],
            'FOOD' => [
                'Food Expense Assistance',
                'Groceries',
                'Meals'
            ],
            'CRISIS SERVICES' => ['Law Enforcement/Emergency Services'],
            'HEALTH CARE' => [
                'Medical Facilities',
                'Health Insurance & Medical Expense Assistance',
                'Specialty Screenings & Services',
                'Dental Care',
                'Immunizations',
                'Sexual & Reproductive Health',
                'Home Nursing & Caregiving',
                'End of Life Care'
            ],
            'MENTAL HEALTH' => [
                'Counseling',
                'Grief & Loss',
                'Addiction',
                'Abuse',
                'Other Support Groups',
                'Psychiatric Services'
            ],
            'SUBSTANCE USE DISORDER' => [
                'Education & Prevention',
                'Alcohol Treatment & Facilities',
                'Drug Treatment & Facilities'
            ],
            'CHILDREN & FAMILY' => [
                'Family Resource Centers',
                'Parenting Resources',
                'Expectant & New Parents',
                'Child Care & Early Education',
                'Foster Care & Adoption',
                'Family Counseling',
                'Military Families'
            ],
            'YOUTH' => [
                'Youth Programs',
                'Prevention & Intervention',
                'Teen Pregnancy'
            ],
            'SENIORS' => [
                'Senior Centers',
                'Senior Support Services',
                'Senior Health Care',
                'Senior Housing',
                'Senior Meals'
            ],
            'EDUCATION' => [
                'Education Programs',
                'Educational Services',
                'Schools & Libraries',
                'Computer Literacy'
            ],
            'LEGAL ASSISTANCE' => [
                'Records & Certificates',
                'General Legal Services',
                'Family Law',
                'Citizenship and Immigration',
                'Victim Assistance',
                'Courts'
            ]

        }.each do |category_name, sub_category_names|
          category = OCR::Category.unconfirmed.find_by(name: category_name.downcase.titleize)
          cat_count += 1
          sub_cats = sub_category_names.map do |name|
            OCR::SubCategory.setup_sub_category(category, name)
          end.compact

          Rails.logger.info "Category #{cat_count}/#{total_cat_count} (#{category_name}): Getting #{sub_cats.count} SubCategories..."
          @errors += save_and_log_errors(sub_cats)
          raise "ERROR LOADING REFERNET SUB-CATEGORIES" unless @errors.empty?
        end

        Rails.logger.info "*** Successfully Loaded #{OCR::SubCategory.unconfirmed.count} SubCategories ***"

        
      rescue => e
        catch_refernet_load_errors(e, OCR::SubCategory, @errors)
      end
        
    end
    
    desc "Load SubSubCategories from ReferNET"
    task :sub_sub_categories, [:google_api_key] =>  [:prepare] do |t,args|

        if args[:google_api_key]
          puts 'Using Google Translate'
          gt = OneclickRefernet::GoogleTranslate.new(args[:google_api_key])
        else
          puts 'Using Fake Translate'
        end

        begin
        OCR::SubSubCategory.destroy_unconfirmed # First, clear out all unconfirmed subsubcategories before loading new ones

        filename = File.join(OCR::Engine.root,"db/data", 'ventura211_sub_sub_categories.csv')

        puts "Processing #{filename}"

        CSV.foreach(filename, :headers => true, :col_sep => "," ) do |row|

          next nil unless row[0].present? && row[2].present?
          name = row[2]
          Rails.logger.debug "Building new sub_sub_category with name: #{name}"
          new_sub_sub_category = OCR::SubCategory.find_by(name: row[0]).sub_sub_categories.build(
              name: name,
              code: name.to_s.strip.parameterize.underscore, # Convert name to a snake case code string,
              taxonomy_code: OCR::SubSubCategory.refernet_service.get_taxonomy_code(name),
              confirmed: false
          )

          @errors += save_and_log_errors([new_sub_sub_category])
          raise "ERROR LOADING REFERNET SUB-SUB-CATEGORIES" unless @errors.empty?

          puts "------------------Translating #{new_sub_sub_category.class.name} #{new_sub_sub_category.name} ------------------"

          # Only translate available locales with missing translations
          I18n.available_locales.each do |locale|

            if(locale == :en) # If locale is English, simply titleize the code
              translated = row[1]
            else # Otherwise, translate the titleized code into the given locale
              if(args[:google_api_key]) # GOOGLE Translate
                translated = gt.translate(new_sub_sub_category.name, locale.to_s, :en)
              else # Fake Translate
                translated = "#{locale}_#{new_sub_sub_category.code}"
              end
            end

            # Set the translation and increment the counter
            new_sub_sub_category.set_translated_name(locale, translated)

          end # locales.each
        end
      rescue => e
        catch_refernet_load_errors(e, OCR::SubSubCategory, @errors)
      end

    end
  end
end
