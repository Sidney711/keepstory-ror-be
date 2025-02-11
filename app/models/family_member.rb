class FamilyMember < ApplicationRecord
  belongs_to :family

  validates :first_name, :last_name, presence: true
end
