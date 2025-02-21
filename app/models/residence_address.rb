class ResidenceAddress < ApplicationRecord
  belongs_to :family_member

  validates :address, length: { maximum: 250 }
  validates :period, length: { maximum: 100 }
end