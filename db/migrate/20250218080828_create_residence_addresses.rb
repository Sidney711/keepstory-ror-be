class CreateResidenceAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :residence_addresses do |t|
      t.references :family_member, null: false, foreign_key: true
      t.string :address, limit: 250
      t.string :period, limit: 100

      t.timestamps
    end
  end
end
