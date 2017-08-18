class CreateOneclickRefernetServicesSubSubCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :oneclick_refernet_services_sub_sub_categories do |t|
      t.references :service, foreign_key: true, index: { name: :idx_svcs_cat_join_table_on_service_id }
      t.references :sub_sub_category, foreign_key: true, index: { name: :idx_svcs_cat_join_table_on_sub_sub_category_id }

      t.timestamps
    end
  end
end
