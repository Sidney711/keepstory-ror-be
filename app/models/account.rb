class Account < ApplicationRecord
  include Rodauth::Rails.model

  has_many :families, dependent: :destroy

  enum :status, { unverified: 1, verified: 2, closed: 3 }
end
