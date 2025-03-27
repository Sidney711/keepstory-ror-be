class CreateFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :family_members do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth
      t.date :date_of_death
      t.references :family, null: false, foreign_key: true

      t.timestamps
    end
  end
end
