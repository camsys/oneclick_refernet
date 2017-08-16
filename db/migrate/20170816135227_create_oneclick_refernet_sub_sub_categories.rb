class CreateOneclickRefernetSubSubCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :oneclick_refernet_sub_sub_categories do |t|
      t.string :name, index: true
      t.references :sub_category, foreign_key: true

      t.timestamps
    end
  end
end
