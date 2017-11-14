class AddCodeToCategoryTables < ActiveRecord::Migration[5.0]
  def change
    add_column :oneclick_refernet_categories, :code, :string, index: true
    add_column :oneclick_refernet_sub_categories, :code, :string, index: true
    add_column :oneclick_refernet_sub_sub_categories, :code, :string, index: true
  end
end
