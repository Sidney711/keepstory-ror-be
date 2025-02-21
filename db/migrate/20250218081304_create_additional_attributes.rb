class CreateAdditionalAttributes < ActiveRecord::Migration[8.0]
  def change
    create_table :additional_attributes do |t|
      t.references :family_member, null: false, foreign_key: true
      t.string :attribute_name, limit: 150, null: false
      t.string :long_text, limit: 2000

      t.timestamps
    end
  end
end
