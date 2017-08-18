class RemoveSubSubCategoryReferenceFromServices < ActiveRecord::Migration[5.0]
  def change
    remove_column :oneclick_refernet_services, :sub_sub_category_id, :integer, foreign_key: true
  end
end
