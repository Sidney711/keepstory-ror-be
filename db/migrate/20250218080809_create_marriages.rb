class CreateMarriages < ActiveRecord::Migration[8.0]
  def change
    create_table :marriages do |t|
      t.references :first_partner, null: false, foreign_key: { to_table: :family_members }
      t.references :second_partner, null: false, foreign_key: { to_table: :family_members }
      t.string :period, limit: 100

      t.timestamps
    end
  end
end
