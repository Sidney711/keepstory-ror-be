module Api
  module V1
    class ResidenceAddressResource < JSONAPI::Resource
      attributes :address, :period, :created_at, :updated_at
      has_one :family_member

      def self.records(options = {})
        current_account = options[:context][:current_account]
        current_family = Family.find_by(account_id: current_account.id)
        if current_family
          ResidenceAddress.joins(:family_member).where(family_members: { family_id: current_family.id })
        else
          ResidenceAddress.none
        end
      end
    end
  end
end
