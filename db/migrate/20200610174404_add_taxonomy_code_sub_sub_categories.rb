class AddTaxonomyCodeSubSubCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :oneclick_refernet_sub_sub_categories, :taxonomy_code, :string
  end
end
