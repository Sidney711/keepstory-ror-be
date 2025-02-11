module Api
  module V1
    class FamilyMemberResource < JSONAPI::Resource
      attributes :first_name, :last_name, :date_of_birth, :date_of_death, :created_at, :updated_at

      #has_one :family
    end
  end
end
