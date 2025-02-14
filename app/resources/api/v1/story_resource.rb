module Api
  module V1
    class StoryResource < JSONAPI::Resource
      attributes :title, :content, :date_type, :story_date, :story_year, :is_date_approx, :created_at, :updated_at

      has_many :family_members, inverse: :stories

      def self.creatable_fields(context)
        super + [:family_members]
      end

      def self.updatable_fields(context)
        super + [:family_members]
      end

      def self.records(options = {})
        current_account = options[:context][:current_account]
        current_family = Family.find_by(account_id: current_account.id)
        if current_account && current_family
          Story.where(family_id: current_family.id)
        else
          Story.none
        end
      end
    end
  end
end
