module RefernetTaskHelpers
  
  # TABLES = [OCR::Category, OCR::SubCategory, OCR::SubSubCategory, OCR::Service]

  # Saves a batch of records and returns any errors
  def save_and_log_errors(records)
    records.map do |record|
      { record: record, message: record.errors.full_messages.to_sentence} unless record.save
    end.compact
  end

  # Logs and rolls back changes after catching an error attempting to load a refernet table
  def catch_refernet_load_errors(e, table, errors=[])
    Rails.logger.error e
    Rails.logger.error "ERROR MESSAGES: "
    Rails.logger.error errors
    reject_table(table)
  end
  
  # Rolls back all unconfirmed changes in the table
  def reject_table(table)
    Rails.logger.warn "REJECTING UNCONFIRMED #{table_name(table)}"
    if table.reject_changes.present?
      Rails.logger.warn "SUCCESSFULLY ROLLED BACK CHANGES TO #{table_name(table)}"
    else
      Rails.logger.error "COULD NOT ROLL BACK CHANGES TO #{table_name(table)}"
    end
  end
  
  # Returns a pretty, pluralized, capitalized table name
  def table_name(table)
    table.name.pluralize.upcase.split('::').last
  end

end
