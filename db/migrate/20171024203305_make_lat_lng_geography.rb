class MakeLatLngGeography < ActiveRecord::Migration[5.0]
  def change
    add_column :oneclick_refernet_services, :latlngg, :st_point, geographic: true 
    add_index :oneclick_refernet_services, :latlngg, using: :gist
  end
end
