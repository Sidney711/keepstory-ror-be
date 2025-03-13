class FamilyMember < ApplicationRecord
  belongs_to :family

  has_many :educations, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :residence_addresses, dependent: :destroy
  has_many :additional_attributes, dependent: :destroy
  has_many :family_members_stories, class_name: "FamilyMembersStory", dependent: :delete_all
  has_many :stories, through: :family_members_stories
  has_many :marriages_as_first_partner, class_name: "Marriage", foreign_key: "first_partner_id", dependent: :destroy
  has_many :marriages_as_second_partner, class_name: "Marriage", foreign_key: "second_partner_id", dependent: :destroy
  has_many :children_as_mother, class_name: "FamilyMember", foreign_key: "mother_id", dependent: :nullify
  has_many :children_as_father, class_name: "FamilyMember", foreign_key: "father_id", dependent: :nullify

  belongs_to :mother, class_name: "FamilyMember", optional: true
  belongs_to :father, class_name: "FamilyMember", optional: true

  has_one_attached :signature
  has_one_attached :profile_picture
  has_many_attached :images
  has_many_attached :documents
  has_many_attached :exports

  after_destroy_commit :purge_active_storage_attachments
  before_destroy :store_associated_stories, prepend: true
  after_destroy :cleanup_orphan_stories

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :birth_last_name, length: { maximum: 100 }, allow_blank: true
  validates :birth_place, :death_place, :burial_place, :internment_place, length: { maximum: 250 }, allow_blank: true
  validates :religion, :cause_of_death, length: { maximum: 100 }, allow_blank: true
  validates :profession, :hobbies_and_interests, length: { maximum: 1000 }, allow_blank: true
  validates :short_description, :short_message, length: { maximum: 2000 }, allow_blank: true
  validates :deceased, inclusion: { in: [true, false] }, presence: true

  enum :gender, { male: 1, female: 2, other: 3 }

  validate :birth_date_cannot_be_in_future
  validate :death_date_cannot_be_in_future
  validate :death_date_after_birth_date
  validate :death_date_only_with_deceased
  validate :death_time_only_with_deceased
  validate :death_place_only_with_deceased
  validate :cause_of_death_only_with_deceased
  validate :burial_date_only_with_deceased
  validate :burial_place_only_with_deceased
  validate :internment_place_only_with_deceased

  validate :mother_relationship, if: -> { mother_id.present? }
  validate :father_relationship, if: -> { father_id.present? }
  validate :validate_parent_relationship
  validate :no_circular_parenting

  RELATIONSHIP_TYPES = {
    mother: 'mother',
    father: 'father',
    grandparent: 'grandparent',
    descendant: 'descendant',
    sibling: 'sibling'
  }.freeze

  def export_pdf
    family.export_pdf
  end

  def children
    FamilyMember.where("mother_id = ? OR father_id = ?", self.id, self.id)
  end

  def ancestors
    parents = [mother, father].compact
    parents + parents.flat_map { |p| p.ancestors }
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

  def purge_active_storage_attachments
    signature.purge_later if signature.attached?
    profile_picture.purge_later if profile_picture.attached?
    images.each { |img| img.purge_later }
    documents.each { |doc| doc.purge_later }
    exports.each { |exp| exp.purge_later }
  end

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

  def death_date_only_with_deceased
    if date_of_death.present? && !deceased
      errors.add(:date_of_death, "cannot be set without deceased flag")
    end
  end

  def death_time_only_with_deceased
    if death_time.present? && !deceased
      errors.add(:death_time, "cannot be set without deceased flag")
    end
  end

  def death_place_only_with_deceased
    if death_place.present? && !deceased
      errors.add(:death_place, "cannot be set without deceased flag")
    end
  end

  def cause_of_death_only_with_deceased
    if cause_of_death.present? && !deceased
      errors.add(:cause_of_death, "cannot be set without deceased flag")
    end
  end

  def burial_date_only_with_deceased
    if burial_date.present? && !deceased
      errors.add(:burial_date, "cannot be set without deceased flag")
    end
  end

  def burial_place_only_with_deceased
    if burial_place.present? && !deceased
      errors.add(:burial_place, "cannot be set without deceased flag")
    end
  end

  def internment_place_only_with_deceased
    if internment_place.present? && !deceased
      errors.add(:internment_place, "cannot be set without deceased flag")
    end
  end

  def validate_parent_relationship
    if mother_id.present? && father_id.present? && (mother_id == father_id)
      errors.add(:mother_id, "cannot be the same as the father")
    end

    current_children = children

    if current_children.any? { |child| child.date_of_birth.present? && date_of_birth.present? && child.date_of_birth < date_of_birth }
      errors.add(:date_of_birth, "cannot be before child's birth date")
    end
  end

  def mother_relationship
    if date_of_birth.present? && mother.date_of_birth.present? && date_of_birth < mother.date_of_birth
      errors.add(:date_of_birth, "cannot be before mother's birth date")
    end
  end

  def father_relationship
    if date_of_birth.present? && father.date_of_birth.present? && date_of_birth < father.date_of_birth
      errors.add(:date_of_birth, "cannot be before father's birth date")
    end
  end

  def no_circular_parenting
    if mother.present?
      if mother == self || mother.ancestors.include?(self)
        errors.add(:mother, "cannot be a descendant of this person")
      end
    end

    if father.present?
      if father == self || father.ancestors.include?(self)
        errors.add(:father, "cannot be a descendant of this person")
      end
    end
  end

  def store_associated_stories
    @associated_stories = stories.to_a
  end

  def cleanup_orphan_stories
    @associated_stories.each do |story|
      story.destroy if story.family_members.empty?
    end
  end
end
