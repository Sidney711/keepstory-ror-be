class FamilyMember < ApplicationRecord
  belongs_to :family

  validates :first_name, :last_name, presence: true
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
