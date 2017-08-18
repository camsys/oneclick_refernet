namespace :oneclick_refernet do
  
  require 'tasks/helpers/refernet_task_helpers'
  include RefernetTaskHelpers

  desc "Prepares for Rake Tasks" 
  task prepare_environment: :environment do
    
    # Set the logger to log to the console
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = 1
    
    # Set short-hand variable names for constants
    Category = OneclickRefernet::Category
    SubCategory = OneclickRefernet::SubCategory
    SubSubCategory = OneclickRefernet::SubSubCategory
    Service = OneclickRefernet::Service
    RefernetService = OneclickRefernet::RefernetService

  end
  
  desc "Load Categories Structure from Refernet"
  task load_database: :prepare_environment do
    Rails.logger.info "Loading Categories and Services..."
    rs = RefernetService.new
    errors = []
    tables = [Category, SubCategory, SubSubCategory, Service]
    
    # Start mucking with the database, but catch any errors.
    begin
    
      # First, clear out all unconfirmed categories
      tables.map(&:destroy_unconfirmed)
      
      # Build the whole tree of categories, sub-categories, and sub-sub-categories
      
      ### CATEGORIES ###
      new_categories = Category.fetch_all.compact
      errors += save_and_log_errors(new_categories)
            
      ### SUB CATEGORIES ###
      new_sub_categories = new_categories.flat_map do |cat|
        Rails.logger.info "Getting subcategories for #{cat.name}..."
        sub_cats = SubCategory.fetch_by_category(cat)
        errors += save_and_log_errors(sub_cats)
        next sub_cats
      end
            
      ### SUB SUB CATEGORIES ###
      new_sub_sub_categories = new_sub_categories.flat_map do |sub_cat|
        Rails.logger.info "Getting sub_sub_categories for #{sub_cat.name}: #{sub_cat.refernet_category_id}..."
        sub_sub_cats = SubSubCategory.fetch_by_sub_category(sub_cat)
        errors += save_and_log_errors(sub_sub_cats)
        next sub_sub_cats
      end
      
      ### SERVICES ###
      new_services = new_sub_sub_categories.flat_map do |sub_sub_cat|
        Rails.logger.info "Getting services for #{sub_sub_cat.name}..."
        services = Service.fetch_by_sub_sub_category(sub_sub_cat)
        errors += save_and_log_errors(services)
        next services
      end
      
      # Check to see if any errors occurred. If not, approve the new categories and services.
      # Otherwise, raise an exception.
      if errors.empty?
        Rails.logger.info "Confirming New Categories and Services..."
        tables.each do |table|
          table.approve_changes and Rails.logger.info "Created #{table.count} #{table.to_s.pluralize}."
        end
      else
        raise "ERROR LOADING REFERNET DATABASE"
      end
    
    # If there were any errors at all, display a notification and roll back the changes.
    rescue => e
      Rails.logger.error e
      Rails.logger.error errors.ai
      Rails.logger.warn "Rejecting New Categories and Services..."
      tables.map(&:reject_changes) and Rails.logger.warn "REJECTION COMPLETE"
    end
  
  end
  
end
