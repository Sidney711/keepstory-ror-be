module Api
  module V1
    class MarriageResource < JSONAPI::Resource
      attributes :period, :created_at, :updated_at
      has_one :first_partner, class_name: 'FamilyMember'
      has_one :second_partner, class_name: 'FamilyMember'

      def self.records(options = {})
        current_account = options[:context][:current_account]
        current_family = Family.find_by(account_id: current_account.id)
        if current_family
          Marriage.joins("INNER JOIN family_members AS fp ON marriages.first_partner_id = fp.id")
                  .joins("INNER JOIN family_members AS sp ON marriages.second_partner_id = sp.id")
                  .where("fp.family_id = ? AND sp.family_id = ?", current_family.id, current_family.id)
        else
          Marriage.none
        end
      end
    end
  end
end
