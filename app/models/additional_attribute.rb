class AdditionalAttribute < ApplicationRecord
  belongs_to :family_member

  has_one_attached :file

  validates :attribute_name, presence: true, length: { maximum: 150 }
  validates :short_text, length: { maximum: 150 }, allow_blank: true
  validates :long_text, length: { maximum: 2000 }, allow_blank: true

  validate :only_one_value_present

  private

  def only_one_value_present
    values = [short_text.present?, long_text.present?, file.attached?]
    if values.count(true) > 1
      errors.add(:base, "Only one type of value (short text, long text or file) can be provided.")
    end
  end
end
