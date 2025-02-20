module Api
  module V1
    class AdditionalAttributeResource < JSONAPI::Resource
      attributes :attribute_name, :long_text, :created_at, :updated_at
      has_one :family_member

      def self.records(options = {})
        current_account = options[:context][:current_account]
        current_family = Family.find_by(account_id: current_account.id)
        if current_family
          AdditionalAttribute.joins(:family_member).where(family_members: { family_id: current_family.id })
        else
          AdditionalAttribute.none
        end
      end
    end
  end
end