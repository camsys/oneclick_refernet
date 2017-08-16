class CreateOneclickRefernetSubCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :oneclick_refernet_sub_categories do |t|
      t.string :name, index: true
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
