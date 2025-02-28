class RemoveDeathDateFromFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    remove_column :family_members, :death_date, :date
  end
end
