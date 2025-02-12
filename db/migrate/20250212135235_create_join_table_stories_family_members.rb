class CreateJoinTableStoriesFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    create_join_table :stories, :family_members do |t|
      t.index :story_id
      t.index :family_member_id
    end
  end
end
