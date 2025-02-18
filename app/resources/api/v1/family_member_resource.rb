module Api
  module V1
    class FamilyMemberResource < JSONAPI::Resource
      attributes :first_name,
                 :last_name,
                 :date_of_birth,
                 :date_of_death,
                 :birth_last_name,
                 :birth_place,
                 :birth_time,
                 :gender,
                 :religion,
                 :deceased,
                 :death_date,
                 :death_time,
                 :death_place,
                 :cause_of_death,
                 :burial_date,
                 :burial_place,
                 :internment_place,
                 :profession,
                 :hobbies_and_interests,
                 :short_description,
                 :short_message,
                 :created_at,
                 :updated_at

      has_many :stories, inverse: :family_members
      has_many :educations
      has_many :employments
      has_many :residence_addresses
      has_many :additional_attributes
      has_many :marriages_as_first_partner, class_name: 'Marriage'
      has_many :marriages_as_second_partner, class_name: 'Marriage'

      # # Virtuální atributy pro Active Storage soubory
      # attribute :signature_url, format: :default
      # attribute :profile_picture_url, format: :default
      #
      # def signature_url
      #   # Použijte metodu 'model' namísto 'object'
      #   if model.signature.attached?
      #     context[:url_helpers].rails_blob_url(model.signature, only_path: true)
      #   end
      # end
      #
      # def profile_picture_url
      #   if model.profile_picture.attached?
      #     context[:url_helpers].rails_blob_url(model.profile_picture, only_path: true)
      #   end
      # end

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
