class Story < ApplicationRecord
  belongs_to :family
  has_and_belongs_to_many :family_members

  validates :title, presence: true
  validates :date_type, inclusion: { in: ['exact', 'year'] }
  validate :validate_date_presence

  before_validation :clear_opposite_date_field

  private

  def clear_opposite_date_field
    if date_type == 'exact'
      self.story_year = nil
    elsif date_type == 'year'
      self.story_date = nil
    end
  end

  def validate_date_presence
    if date_type == 'exact' && story_date.blank?
      errors.add(:story_date, "must be provided for exact date type")
    elsif date_type == 'year' && story_year.blank?
      errors.add(:story_year, "must be provided for year date type")
    end
  end
end
