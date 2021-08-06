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
  task :load_database_on_sunday, [:google_api_key, :incremental] =>  [:prepare_environment] do |t,args|
    # Runs load_database only if it's Sunday
    if DateTime.now.wday == 0
      Rails.logger.info "It's Sunday! Running the load database task..."
      Rake::Task["oneclick_refernet:load:database"].invoke(args[:google_api_key], args[:incremental])
    else
      Rails.logger.info "Not running the load database task because it isn't Sunday."
    end
  end

  desc "Alias for load:database task"
  task :load_database, [:google_api_key, :incremental] => ["load:database"]
  
  ### TASKS FOR LOADING REFERNET DATA ###
  namespace :load do

    
    desc "Prepare to Load ReferNET Database"
    task prepare: :prepare_environment do
      @errors ||= []
      @tables = [OCR::Category, OCR::SubCategory, OCR::SubSubCategory, OCR::Service]
    end    


    # RUN THIS ONLY WHEN THE CATEGORY HIERARCHY CHANGES
    desc "LOAD INITAL CATEGORIES Tables"
    task :category_hierarchy, [:google_api_key, :incremental] => [:prepare] do |t,args|

      Rails.logger.info "*** LOADING AZURE CATEGORIES ***"

      ### LOAD ALL DATABASE TABLES ###
      Rake::Task["ventura:load:categories"].invoke
      Rake::Task["ventura:load:sub_categories"].invoke
      Rake::Task["ventura:load:sub_sub_categories"].invoke
      
      ### TRANSLATE ALL TABLES ###
      Rake::Task["oneclick_refernet:translate:categories"].invoke(args[:google_api_key])
      
      Rails.logger.info "*** COMPLETED LOADING AZURE CATEGORIES ***"
    end
    
    desc "Load, Confirm, and Translate all ReferNET Tables"
    task :database, [:google_api_key, :incremental] => [:prepare] do |t,args|

      Rails.logger.info "*** LOADING AZURE SERVICES ***"

      ### LOAD ALL DATABASE TABLES ###
      Rake::Task["ventura:load:services"].invoke(args[:incremental] || false)
      
      ### TRANSLATE ALL TABLES ###
      Rake::Task["oneclick_refernet:translate:services"].invoke(args[:google_api_key])
      
      Rails.logger.info "*** COMPLETED LOADING REFERNET DATABASE ***"
    end

    desc "Load Categories for Ventura"
    task categories: :prepare do

      if OCR::Category.count != 0
        puts "CATEGORIES HAVE ALREADY BEEN LOADED"
        next
      end

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
      ].each do |category_name|
        cat = OCR::Category.setup_category(category_name.downcase.titleize)
        cat.confirmed = true 
        cat.save! 
      end
    end
    
    desc "Load SubCategories for Ventura"
    task sub_categories: :prepare do

      if OCR::SubCategory.count != 0
        puts "SUB-CATEGORIES HAVE ALREADY BEEN LOADED"
        next
      end

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
          'CRISIS SERVICES' => [
            'Extreme Heat Cool Centers',
            'Law Enforcement/Emergency Services'
          ],
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
        category = OCR::Category.find_by(name: category_name.downcase.titleize)
        sub_category_names.each do |name|
          sub_cat = OCR::SubCategory.setup_sub_category(category, name)
          sub_cat.confirmed = true 
          sub_cat.save!
        end
      end
    end
    
    desc "Load SubSubCategories for Ventura from CSV"
    task :sub_sub_categories, [:google_api_key] =>  [:prepare] do |t,args|
      if OCR::SubSubCategory.count != 0
        puts "SUB-SUB-CATEGORIES HAVE ALREADY BEEN LOADED"
        next
      end
      filename = File.join(OCR::Engine.root,"db/data", 'ventura211_sub_sub_categories.csv')

      puts "Processing #{filename}"

      CSV.foreach(filename, :headers => true, :col_sep => "," ) do |row|

        next nil unless row[0].present? && row[2].present?
        name = row[2]
        Rails.logger.debug "Building new sub_sub_category with name: #{name}"
        new_sub_sub_category = OCR::SubCategory.find_by(name: row[0]).sub_sub_categories.build(
            name: name,
            code: name.to_s.strip.parameterize.underscore, # Convert name to a snake case code string,
            taxonomy_code: 'na',
            confirmed: true
        )
        new_sub_sub_category.save!
      end

    end #sub_sub_categories

    desc "Create new sub_category and sub_sub_category under the specified category"
    task :create_sub_categories, [:category_name, :sub_category_name, :sub_sub_category_name] => [:prepare] do |t,args|
      # Look up existing category.
      category = OCR::Category.find_by(name: args[:category_name].downcase.titleize)
      # Create new sub_category under existing category.
      Rails.logger.debug "Building new sub_category with name: #{args[:sub_category_name]}"
      OCR::SubCategory.setup_sub_category(category, args[:sub_category_name])
      sub_cat.confirmed = true 
      sub_cat.save!
      # Create new sub_sub_category under new sub_category.
      Rails.logger.debug "Building new sub_sub_category with name: #{args[:sub_sub_category_name]}"
      new_sub_sub_category = OCR::SubCategory.find_by(name: args[:sub_category_name]).sub_sub_categories.build(
          name: args[:sub_sub_category_name],
          code: args[:sub_sub_category_name].to_s.strip.parameterize.underscore, # Convert name to a snake case code string,
          taxonomy_code: 'na',
          confirmed: true
      )
      new_sub_sub_category.save!
    end

    desc "Load services from Azure"
    task :services, [:incremental] => [:prepare] do |t,args|
      if args[:incremental] == "true" #Only pull in services from the past 3 weeks
        puts 'LOADING SERVICES UPDATED IN THE PAST 4 WEEKS'
        OCR::Service.create_from_azure Time.now-4.weeks 
      else #Upload Everything
        puts 'LOADING ALL SERVICES'
        OCR::Service.create_from_azure
      end
    end

  end #load
end #ventura
