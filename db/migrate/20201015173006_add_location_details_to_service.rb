class AddLocationDetailsToService < ActiveRecord::Migration[5.0]
  def change
    add_column :oneclick_refernet_services, :location_details, :text
  end
end
