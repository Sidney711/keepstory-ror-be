class AdditionalAttribute < ApplicationRecord
  belongs_to :family_member

  validates :attribute_name, presence: true, length: { maximum: 150 }
  validates :long_text, length: { maximum: 2000 }, allow_blank: true
end
