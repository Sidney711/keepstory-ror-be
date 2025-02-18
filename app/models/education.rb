class Education < ApplicationRecord
  belongs_to :family_member

  validates :school_name, length: { maximum: 250 }
  validates :address, length: { maximum: 250 }
  validates :period, length: { maximum: 100 }
end