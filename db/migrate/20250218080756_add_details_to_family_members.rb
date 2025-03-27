class AddDetailsToFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    change_column :family_members, :first_name, :string, limit: 100, null: false
    change_column :family_members, :last_name, :string, limit: 100, null: false

    add_column :family_members, :birth_last_name, :string, limit: 100
    add_column :family_members, :birth_place, :string, limit: 250
    add_column :family_members, :birth_time, :time

    add_column :family_members, :gender, :integer
    add_column :family_members, :religion, :string, limit: 100

    add_column :family_members, :deceased, :boolean, default: false
    add_column :family_members, :death_date, :date
    add_column :family_members, :death_time, :time
    add_column :family_members, :death_place, :string, limit: 250
    add_column :family_members, :cause_of_death, :string, limit: 100

    add_column :family_members, :burial_date, :date
    add_column :family_members, :burial_place, :string, limit: 250
    add_column :family_members, :internment_place, :string, limit: 250

    add_reference :family_members, :mother, foreign_key: { to_table: :family_members }
    add_reference :family_members, :father, foreign_key: { to_table: :family_members }

    add_column :family_members, :profession, :string, limit: 1000
    add_column :family_members, :hobbies_and_interests, :string, limit: 1000
    add_column :family_members, :short_description, :string, limit: 2000
    add_column :family_members, :short_message, :string, limit: 2000
  end
end