class Family < ApplicationRecord
  has_many :family_members, dependent: :destroy
  has_many_attached :exports

  before_create :set_uuid

  private

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
