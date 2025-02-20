module Api
  module V1
    class AdditionalAttributeResource < JSONAPI::Resource
      attributes :attribute_name, :short_text, :long_text, :created_at, :updated_at
      attribute :file_url, format: :default

      has_one :family_member

      def file_url
        if object.file.attached?
          context[:url_helpers].rails_blob_url(object.file, only_path: true)
        end
      end

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
