class AddRefernetCategoryIdToSubCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :oneclick_refernet_sub_categories, :refernet_category_id, :integer
  end
end
