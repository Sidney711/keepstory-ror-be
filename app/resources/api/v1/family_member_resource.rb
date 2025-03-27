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
                 :updated_at,
                 :relationship_tree,
                 :marriage_details,
                 :education_details,
                 :employment_details,
                 :residence_address_details,
                 :profile_picture_url,
                 :signature_url,
                 :additional_attribute_details

      filters :search
      paginator :custom

      has_many :stories, inverse: :family_members
      has_many :educations
      has_many :employments
      has_many :residence_addresses
      has_many :additional_attributes
      has_many :marriages_as_first_partner, class_name: 'Marriage'
      has_many :marriages_as_second_partner, class_name: 'Marriage'

      has_one :mother, class_name: 'FamilyMember'
      has_one :father, class_name: 'FamilyMember'

      def self.default_page_size
        12
      end

      def self.maximum_page_size
        12
      end

      def meta(options)
        paginator = options[:paginator]
        total_pages = paginator ? paginator.total_pages : 1
        { total_pages: total_pages }
      end

      def profile_picture_url
        url_helpers = context[:url_helpers] || Rails.application.routes.url_helpers
        if _model.profile_picture.attached?
          url_helpers.rails_blob_url(_model.profile_picture, only_path: true)
        else
          nil
        end
      end

      def signature_url
        url_helpers = context[:url_helpers] || Rails.application.routes.url_helpers
        if _model.signature.attached?
          url_helpers.rails_blob_url(_model.signature, only_path: true)
        else
          nil
        end
      end

      def relationship_tree
        @model.relationship_tree
      end

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

      def self.apply_filter(records, filter, value, options)
        if filter.to_s == "search"
          search_term = value&.first&.strip
          if search_term&.include?(" ")
            parts = search_term.split(/\s+/)
            first_part = parts.first
            last_part  = parts.last
            records.where(
              "(family_members.first_name ILIKE ? AND family_members.last_name ILIKE ?) OR (family_members.first_name ILIKE ? AND family_members.last_name ILIKE ?)",
              "%#{first_part}%", "%#{last_part}%",
              "%#{last_part}%", "%#{first_part}%"
            )
          else
            records.where(
              "family_members.first_name ILIKE ? OR family_members.last_name ILIKE ?",
              "%#{search_term}%", "%#{search_term}%"
            )
          end
        else
          super(records, filter, value, options)
        end
      end
    end
  end
end
