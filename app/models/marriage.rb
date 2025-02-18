class Marriage < ApplicationRecord
  belongs_to :first_partner, class_name: "FamilyMember"
  belongs_to :second_partner, class_name: "FamilyMember"

  validates :period, length: { maximum: 100 }
end