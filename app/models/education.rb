class Education < ApplicationRecord
  belongs_to :family_member

  validates :school_name, length: { maximum: 250 }, presence: true
  validates :address, length: { maximum: 250 }, allow_blank: true
  validates :period, length: { maximum: 100 }, allow_blank: true
end