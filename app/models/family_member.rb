class FamilyMember < ApplicationRecord
  belongs_to :family
  has_and_belongs_to_many :stories

  has_many :educations, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :residence_addresses, dependent: :destroy
  has_many :additional_attributes, dependent: :destroy
  has_many :marriages_as_first_partner, class_name: "Marriage", foreign_key: "first_partner_id", dependent: :destroy
  has_many :marriages_as_second_partner, class_name: "Marriage", foreign_key: "second_partner_id", dependent: :destroy

  belongs_to :mother, class_name: "FamilyMember", optional: true
  belongs_to :father, class_name: "FamilyMember", optional: true

  has_one_attached :signature
  has_one_attached :profile_picture

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :birth_last_name, length: { maximum: 100 }, allow_blank: true
  validates :birth_place, :death_place, :burial_place, :internment_place, length: { maximum: 250 }, allow_blank: true
  validates :religion, length: { maximum: 100 }, allow_blank: true
  validates :profession, :hobbies_and_interests, length: { maximum: 1000 }, allow_blank: true
  validates :short_description, :short_message, length: { maximum: 2000 }, allow_blank: true

  enum :gender, { male: 1, female: 2, other: 3 }

  validate :birth_date_cannot_be_in_future
  validate :death_date_cannot_be_in_future
  validate :death_date_after_birth_date

  private

  def birth_date_cannot_be_in_future
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, "cannot be in the future")
    end
  end

  def death_date_cannot_be_in_future
    if date_of_death.present? && date_of_death > Date.today
      errors.add(:date_of_death, "cannot be in the future")
    end
  end

  def death_date_after_birth_date
    if date_of_birth.present? && date_of_death.present? && date_of_death < date_of_birth
      errors.add(:date_of_death, "cannot be before birth date")
    end
  end
end
