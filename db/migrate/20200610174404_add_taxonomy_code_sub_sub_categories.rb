class AddTaxonomyCodeSubSubCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :oneclick_refernet_sub_sub_categories, :taxonomy_code, :string

    change_column :oneclick_refernet_sub_sub_categories,  :refernet_category_id, :string
    change_column :oneclick_refernet_services, :refernet_service_id, :string
    change_column :oneclick_refernet_services, :refernet_location_id, :string
    change_column :oneclick_refernet_services, :refernet_servicesite_id, :string
  end
end