class Family < ApplicationRecord
  belongs_to :account

  has_many :family_members, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many_attached :exports

  before_create :set_uuid

  private

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
