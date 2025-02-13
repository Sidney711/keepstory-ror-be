module Api
  module V1
    class FamilyMemberResource < JSONAPI::Resource
      attributes :first_name, :last_name, :date_of_birth, :date_of_death, :created_at, :updated_at

      has_many :stories, inverse: :family_members

      def self.creatable_fields(context)
        super - [:family_id]
      end

      def self.updatable_fields(context)
        super - [:family_id]
      end

      def self.records(options = {})
        current_account = options[:context][:current_account]
        current_family = Family.where(account_id: current_account.id).first
        if current_account && current_family
          FamilyMember.where(family_id: current_family.id)
        else
          FamilyMember.none
        end
      end
    end
  end
end
