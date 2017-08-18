module RefernetTaskHelpers

  # Saves a batch of records and returns any errors
  def save_and_log_errors(records)
    records.map do |record|
      { record: record, message: record.errors.full_messages.to_sentence} unless record.save
    end.compact
  end

end
