module Api
  module V1
    class EmploymentsController < ApplicationController
      before_action :authenticate

      def create
        family = Family.find_by(account_id: current_account.id)
        unless family
          render json: { errors: ["Family was not found."] }, status: :unprocessable_entity and return
        end

        employment = Employment.new(employment_params)
        relationships = params[:data][:relationships] rescue nil

        if relationships && relationships["family_member"].present?
          family_member_id = relationships["family_member"]["data"]["id"] rescue nil
          allowed_ids = family.family_members.where(id: family_member_id).pluck(:id)
          if allowed_ids.include?(family_member_id.to_i)
            employment.family_member_id = family_member_id
          else
            render json: { errors: ["Family member is not allowed."] }, status: :unprocessable_entity and return
          end
        else
          render json: { errors: ["Family member relationship must be provided."] }, status: :unprocessable_entity and return
        end

        if employment.save
          render json: EmploymentResource.new(employment, {}).as_json, status: :created
        else
          render json: { errors: employment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        employment = Employment.find(params[:id])
        family = Family.find_by(account_id: current_account.id)
        unless family && employment.family_member && employment.family_member.family_id == family.id
          render json: { errors: ["Employment not found or not authorized."] }, status: :unprocessable_entity and return
        end

        relationships = params[:data][:relationships] rescue nil
        if relationships && relationships["family_member"].present?
          family_member_id = relationships["family_member"]["data"]["id"] rescue nil
          allowed_ids = family.family_members.where(id: family_member_id).pluck(:id)
          if allowed_ids.include?(family_member_id.to_i)
            employment.family_member_id = family_member_id
          else
            render json: { errors: ["Family member is not allowed."] }, status: :unprocessable_entity and return
          end
        end

        if employment.update(employment_params)
          render json: EmploymentResource.new(employment, {}).as_json, status: :ok
        else
          render json: { errors: employment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        employment = Employment.find(params[:id])
        family = Family.find_by(account_id: current_account.id)
        unless family && employment.family_member && employment.family_member.family_id == family.id
          render json: { errors: ["Employment not found or not authorized."] }, status: :unprocessable_entity and return
        end

        if employment.destroy
          head :no_content
        else
          render json: { errors: employment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def employment_params
        params.require(:data).require(:attributes).permit(:employer, :address, :period)
      end
    end
  end
end
