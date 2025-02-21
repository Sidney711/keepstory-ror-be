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
  has_many_attached :images
  has_many_attached :documents

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

  RELATIONSHIP_TYPES = {
    mother: 'mother',
    father: 'father',
    grandparent: 'grandparent',
    descendant: 'descendant',
    sibling: 'sibling'
  }.freeze

  def children
    FamilyMember.where("mother_id = ? OR father_id = ?", self.id, self.id)
  end

  def relationship_tree
    relationships = []

    if mother
      relationships << {
        'id' => mother.id,
        'first-name' => mother.first_name,
        'last-name' => mother.last_name,
        'relationship' => RELATIONSHIP_TYPES[:mother]
      }
    end

    if father
      relationships << {
        'id' => father.id,
        'first-name' => father.first_name,
        'last-name' => father.last_name,
        'relationship' => RELATIONSHIP_TYPES[:father]
      }
    end

    # Prarodiče
    if mother&.mother
      relationships << {
        'id' => mother.mother.id,
        'first-name' => mother.mother.first_name,
        'last-name' => mother.mother.last_name,
        'relationship' => RELATIONSHIP_TYPES[:grandparent]
      }
    end

    if mother&.father
      relationships << {
        'id' => mother.father.id,
        'first-name' => mother.father.first_name,
        'last-name' => mother.father.last_name,
        'relationship' => RELATIONSHIP_TYPES[:grandparent]
      }
    end

    if father&.mother
      relationships << {
        'id' => father.mother.id,
        'first-name' => father.mother.first_name,
        'last-name' => father.mother.last_name,
        'relationship' => RELATIONSHIP_TYPES[:grandparent]
      }
    end

    if father&.father
      relationships << {
        'id' => father.father.id,
        'first-name' => father.father.first_name,
        'last-name' => father.father.last_name,
        'relationship' => RELATIONSHIP_TYPES[:grandparent]
      }
    end

    siblings = []
    if mother && father
      siblings = FamilyMember.where("(mother_id = ? OR father_id = ?) AND id != ?", mother.id, father.id, id)
    elsif mother
      siblings = FamilyMember.where("mother_id = ? AND id != ?", mother.id, id)
    elsif father
      siblings = FamilyMember.where("father_id = ? AND id != ?", father.id, id)
    end

    siblings.each do |sibling|
      relationships << {
        'id' => sibling.id,
        'first-name' => sibling.first_name,
        'last-name' => sibling.last_name,
        'relationship' => RELATIONSHIP_TYPES[:sibling]
      }
    end

    children.each do |child|
      relationships << {
        'id' => child.id,
        'first-name' => child.first_name,
        'last-name' => child.last_name,
        'relationship' => RELATIONSHIP_TYPES[:descendant]
      }
    end

    relationships
  end

  def marriage_details
    marriages = []

    marriages_as_first_partner.each do |marriage|
      partner = marriage.second_partner
      marriages << {
        id: marriage.id,
        'partner-id' => partner.id,
        'first-name' => partner.first_name,
        'last-name' => partner.last_name,
        'period' => marriage.period
      }
    end

    marriages_as_second_partner.each do |marriage|
      partner = marriage.first_partner
      marriages << {
        id: marriage.id,
        'partner-id' => partner.id,
        'first-name' => partner.first_name,
        'last-name' => partner.last_name,
        'period' => marriage.period
      }
    end

    marriages
  end

  def education_details
    educations.map do |education|
      {
        id: education.id,
        'school-name' => education.school_name,
        address: education.address,
        period: education.period
      }
    end
  end

  def additional_attribute_details
    additional_attributes.map do |additional_attribute|
      {
        id: additional_attribute.id,
        'attribute-name': additional_attribute.attribute_name,
        'long-text': additional_attribute.long_text
      }
    end
  end

  def employment_details
    employments.map do |employment|
      {
        id: employment.id,
        employer: employment.employer,
        address: employment.address,
        period: employment.period
      }
    end
  end

  def residence_address_details
    residence_addresses.map do |residence_address|
      {
        id: residence_address.id,
        address: residence_address.address,
        period: residence_address.period
      }
    end
  end

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
