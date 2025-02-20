module Api
  module V1
    class EmploymentResource < JSONAPI::Resource
      attributes :employer, :address, :period, :created_at, :updated_at
      has_one :family_member

      def self.records(options = {})
        current_account = options[:context][:current_account]
        current_family = Family.find_by(account_id: current_account.id)
        if current_family
          Employment.joins(:family_member).where(family_members: { family_id: current_family.id })
        else
          Employment.none
        end
      end
    end
  end
end
