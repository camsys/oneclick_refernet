class CreateOneclickRefernetCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :oneclick_refernet_categories do |t|
      t.string :name, index: true

      t.timestamps
    end
  end
end
