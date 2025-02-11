class CreateFamilies < ActiveRecord::Migration[8.0]
  def change
    create_table :families do |t|
      t.string :uuid, null: false
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    add_index :families, :uuid, unique: true
  end
end
