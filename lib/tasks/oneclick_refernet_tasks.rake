namespace :oneclick_refernet do
  
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
      Rake::Task["oneclick_refernet:load:all"].invoke
      
      ### CONFIRM CHANGES ###
      Rake::Task["oneclick_refernet:load:confirm"].invoke
      
      ### LOAD SERVICE DETAILS ###
      Rake::Task["oneclick_refernet:load:service_details"].invoke

      ### TRANSLATE ALL TABLES ###
      Rake::Task["oneclick_refernet:translate:all"].invoke(args[:google_api_key])
      
      Rails.logger.info "*** COMPLETED LOADING REFERNET DATABASE ***"
    end
    
    desc "Loads all Tables"
    task all: [
      :categories,
      :sub_categories,
      :sub_sub_categories,
      :services
    ]
  
    desc "Load Categories from ReferNET"
    task categories: :prepare do
      
      begin
      
        OCR::Category.destroy_unconfirmed # First, clear out all unconfirmed categories before loading new ones
        new_categories = OCR::Category.fetch_all.compact
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
        OCR::Category.unconfirmed.each do |cat|
          cat_count += 1
          sub_cats = OCR::SubCategory.fetch_by_category(cat)
          Rails.logger.info "Category #{cat_count}/#{total_cat_count} (#{cat.name}): Getting #{sub_cats.count} SubCategories..."
          @errors += save_and_log_errors(sub_cats)
          raise "ERROR LOADING REFERNET SUB-CATEGORIES" unless @errors.empty?
        end
        
        Rails.logger.info "*** Successfully Loaded #{OCR::SubCategory.unconfirmed.count} SubCategories ***"
        
      rescue => e
        catch_refernet_load_errors(e, OCR::SubCategory, @errors)
      end
        
    end
    
    desc "Load SubSubCategories from ReferNET"
    task sub_sub_categories: :prepare do
      begin
        
        sub_cat_count = 0
        total_sub_cat_count = OCR::SubCategory.unconfirmed.count
        OCR::SubSubCategory.destroy_unconfirmed # First, clear out all unconfirmed subsubcategories before loading new ones
        OCR::SubCategory.unconfirmed.each do |sub_cat|
          sub_cat_count += 1
          sub_sub_cats = OCR::SubSubCategory.fetch_by_sub_category(sub_cat)
          Rails.logger.info "SubCat #{sub_cat_count}/#{total_sub_cat_count} (#{sub_cat.name}): Getting #{sub_sub_cats.count} SubSubCategories..."
          @errors += save_and_log_errors(sub_sub_cats)

          raise "ERROR LOADING REFERNET SUB-SUB-CATEGORIES" unless @errors.empty?
        end
      
        Rails.logger.info "*** Successfully Loaded #{OCR::SubSubCategory.unconfirmed.count} SubSubCategories ***"
        
      rescue => e
        catch_refernet_load_errors(e, OCR::SubSubCategory, @errors)
      end

    end
    
    desc "Load Services from ReferNET"
    task services: :prepare do
      begin
        
        sscat_count = 0
        total_sscat_count = OCR::SubSubCategory.unconfirmed.count
        OCR::Service.destroy_unconfirmed # First, clear out all unconfirmed subsubcategories before loading new ones
        OCR::SubSubCategory.unconfirmed.each do |sub_sub_cat|
          sscat_count += 1
          services = OCR::Service.fetch_by_sub_sub_category(sub_sub_cat)
          Rails.logger.info "SubSubCat #{sscat_count}/#{total_sscat_count} (#{sub_sub_cat.name}): Getting #{services.count} Services..."
          sub_sub_cat.services << services
          @errors += save_and_log_errors(services)
          raise "ERROR LOADING REFERNET SERVICES" unless @errors.empty?
        end
        
        Rails.logger.info "*** Successfully Loaded #{OCR::Service.unconfirmed.count} Services ***"
      
      rescue => e
        catch_refernet_load_errors(e, OCR::Service, @errors)
      end

    end
    
    desc "Confirms All Tables"
    task confirm: :prepare do
      if @errors.empty?
        Rails.logger.info "Confirming New Categories and Services..."
        @tables.each do |table|
          if table.unconfirmed.count > 0
            updated_rows = table.approve_changes
            Rails.logger.info "*** SUCCESSFULLY CONFIRMED #{updated_rows} ROWS IN #{table.name.upcase} TABLE ***"
          else
            Rails.logger.warn "*** NO UNCONFIRMED ROWS FOR #{table.name.upcase} TABLE, SKIPPING CONFIRMATION ***"
          end
        end
      end
    end
    
    desc "Rejects Changes to All Tables, if not yet confirmed"
    task reject: :prepare do
      @tables.each do |table|
        reject_table(table)
      end
    end
    
    desc "Pulls in Service Descriptions"
    task service_details: :prepare do
      Rake::Task["oneclick_refernet:load:#{OCR::Service.refernet_service.class.name.demodulize.underscore}_service_details"].invoke
    end

    desc "Pulls in Service Descriptions from ReferNET"
    task refernet_service_service_details: :prepare do
      begin
        svc_count = 0
        total_svc_count = OCR::Service.confirmed.count
        OCR::Service.confirmed.each do |s|
          svc_count += 1
          Rails.logger.info "Getting Details for Service #{svc_count}/#{total_svc_count} (#{s.agency_name}, #{s.id})"
          s.get_details.each do |detail|
            if detail["Label"]
              s.details["Label_#{detail["Label"].parameterize.underscore}"] = detail["Text"]
              @errors += save_and_log_errors([s])
            end
          end
        end

      rescue => e
        catch_refernet_load_errors(e, OCR::Service, @errors)
      end
    end

    desc "Pulls in Service Descriptions from Azure"
    task azure_service_service_details: :prepare do
      begin
        svc_count = 0
        total_svc_count = OCR::Service.confirmed.count
        OCR::Service.confirmed.each do |s|
          svc_count += 1
          Rails.logger.info "Getting Details for Service #{svc_count}/#{total_svc_count} (#{s.agency_name}, #{s.id})"

          detail = s.get_details

          {
              service_description: 'description',
              eligibility: 'eligibility',
              intake_procedure: 'applicationProcess',
              fees: 'fees',
              program_service_hours: 'schedule',
              documents_required: 'document',
              payment_options: '',
              site_hours: 'locations.schedule',
              languages_spoken: 'language',
              travel_instructions: 'locations.transportation',
              accessibility: 'accessibility'
          }.each do |translation_key, api_column_name|
            col = api_column_name.split('.').last
            if api_column_name.include? 'locations'
              col_value = detail['locations'][0]
            else
              col_value = detail['services'][0]
            end

            col_value = col_value[col]
            s.details["Label_#{translation_key}"] = col_value
          end

          # s.details["Label_area_served"] = detail['services'][0]['serviceArea'].map{|area| "#{area['city']} #{area['state']}"}.join(', ')

          s.details = s.details.merge(detail['locations'][0]['address'].find{|address| address['type'] == 'physical'}) if detail['locations'][0]['address']

          unless detail['services'][0]['phone'].empty?
            detail['services'][0]['phone'].each_with_index do |phone_num, idx|
              s.details["Number_Phone#{idx+1}"] = phone_num['number']
            end
          end

          s.details["email"] = detail['services'][0]['email'] if detail['services'][0]['email'].present?
          s.details["url"] = detail['services'][0]['url'] if detail['services'][0]['url'].present?
          @errors += save_and_log_errors([s])

        end

      rescue => e
        catch_refernet_load_errors(e, OCR::Service, @errors)
      end
    end
    
  end
  
end
