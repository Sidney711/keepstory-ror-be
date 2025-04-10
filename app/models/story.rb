class Story < ApplicationRecord
  belongs_to :family
  has_many :family_members_stories, class_name: "FamilyMembersStory", dependent: :delete_all
  has_many :family_members, through: :family_members_stories

  validates :title, presence: true, length: { maximum: 255 }
  validates :date_type, inclusion: { in: ['exact', 'year'] }
  validates :is_date_approx, inclusion: { in: [true, false] }

  before_validation :clear_opposite_date_field

  validate :date_is_not_in_future
  validate :year_format
  validate :has_at_least_one_family_member

  private

  def clear_opposite_date_field
    if date_type == 'exact'
      self.story_year = nil
    elsif date_type == 'year'
      self.story_date = nil
    end
  end

  def date_is_not_in_future
    if story_date.present? && story_date > Date.today
      errors.add(:story_date, "can't be in the future")
    end
  end

  def year_format
    if story_year.present?
      if story_year < 0
        errors.add(:story_year, "can't be negative")
      end

      if story_year > Date.today.year
        errors.add(:story_year, "can't be in the future")
      end
    end
  end

  def has_at_least_one_family_member
    if family_members.empty?
      errors.add(:base, "Story must have at least one family member")
    end
  end
end
