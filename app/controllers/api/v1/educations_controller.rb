module Api
  module V1
    class EducationsController < ApplicationController
      before_action :authenticate

      def create
        family = Family.find_by(account_id: current_account.id)
        unless family
          render json: { errors: ["Family was not found."] }, status: :unprocessable_entity and return
        end

        education = Education.new(education_params)
        relationships = params[:data][:relationships] rescue nil

        if relationships && relationships["family_member"].present?
          family_member_id = relationships["family_member"]["data"]["id"] rescue nil
          allowed_ids = family.family_members.where(id: family_member_id).pluck(:id)
          if allowed_ids.include?(family_member_id.to_i)
            education.family_member_id = family_member_id
          else
            render json: { errors: ["Family member is not allowed."] }, status: :unprocessable_entity and return
          end
        else
          render json: { errors: ["Family member relationship must be provided."] }, status: :unprocessable_entity and return
        end

        if education.save
          render json: EducationResource.new(education, {}).as_json, status: :created
        else
          render json: { errors: education.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        education = Education.find(params[:id])
        family = Family.find_by(account_id: current_account.id)
        unless family && education.family_member && education.family_member.family_id == family.id
          render json: { errors: ["Education not found or not authorized."] }, status: :unprocessable_entity and return
        end

        relationships = params[:data][:relationships] rescue nil
        if relationships && relationships["family_member"].present?
          family_member_id = relationships["family_member"]["data"]["id"] rescue nil
          allowed_ids = family.family_members.where(id: family_member_id).pluck(:id)
          if allowed_ids.include?(family_member_id.to_i)
            education.family_member_id = family_member_id
          else
            render json: { errors: ["Family member is not allowed."] }, status: :unprocessable_entity and return
          end
        end

        if education.update(education_params)
          render json: EducationResource.new(education, {}).as_json, status: :ok
        else
          render json: { errors: education.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def education_params
        params.require(:data).require(:attributes).permit(:school_name, :address, :period)
      end
    end
  end
end
