class AddDetailsToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :oneclick_refernet_services, :details, :text
  end
end
