module Api
  module V1
    class StoriesController < ApplicationController
      before_action :authenticate

      def create
        family = Family.find_by(account_id: current_account.id)
        unless family
          render json: { errors: ["Family was not found."] }, status: :unprocessable_entity and return
        end

        story = Story.new(story_params)
        story.family = family

        relationships = params[:data][:relationships] rescue nil
        if relationships && relationships["family_members"].present?
          family_members_data = relationships["family_members"]["data"] ||
            relationships["family_members"].deep_symbolize_keys[:data]
          if family_members_data.present?
            submitted_ids = family_members_data.map { |fm| fm["id"] || fm[:id] }
            allowed_ids = family.family_members.where(id: submitted_ids).pluck(:id)
            story.family_member_ids = allowed_ids
          end
        end

        if story.save
          render json: story, status: :created
        else
          render json: { errors: story.errors.full_messages }, status: :unprocessable_entity
        end
      end

      protected

      def update_resource(object, context)
        assign_family_and_family_members(object, context)
        super
      end

      private

      def assign_family_and_family_members(object, context)
        family = Family.find_by(account_id: current_account.id)
        object.family = family if family.present? && object.respond_to?(:family=)

        if params[:data][:relationships].present? && params[:data][:relationships]["family_members"].present?
          family_members_data = params[:data][:relationships]["family_members"]["data"]
          if family_members_data.present?
            submitted_ids = family_members_data.map { |fm| fm["id"] || fm[:id] }
            allowed_ids = family.family_members.where(id: submitted_ids).pluck(:id)
            object.family_member_ids = allowed_ids
          end
        end
      end

      def story_params
        params.require(:data).require(:attributes).permit(
          :title, :content, :date_type, :story_date, :story_year, :is_date_approx
        )
      end
    end
  end
end
