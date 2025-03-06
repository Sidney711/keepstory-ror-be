class FamilyMembersStory < ApplicationRecord
  self.table_name = "family_members_stories"
  self.primary_key = nil

  belongs_to :family_member
  belongs_to :story
end