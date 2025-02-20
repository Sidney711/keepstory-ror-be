module Api
  module V1
    class AdditionalAttributesController < ApplicationController
      before_action :authenticate

      def create
        family = Family.find_by(account_id: current_account.id)
        unless family
          render json: { errors: ["Family was not found."] }, status: :unprocessable_entity and return
        end

        additional_attribute = AdditionalAttribute.new(additional_attribute_params)
        relationships = params[:data][:relationships] rescue nil

        if relationships && relationships["family_member"].present?
          family_member_id = relationships["family_member"]["data"]["id"] rescue nil
          allowed_ids = family.family_members.where(id: family_member_id).pluck(:id)
          if allowed_ids.include?(family_member_id.to_i)
            additional_attribute.family_member_id = family_member_id
          else
            render json: { errors: ["Family member is not allowed."] }, status: :unprocessable_entity and return
          end
        else
          render json: { errors: ["Family member relationship must be provided."] }, status: :unprocessable_entity and return
        end

        if additional_attribute.save
          render json: AdditionalAttributeResource.new(additional_attribute, {}).as_json, status: :created
        else
          render json: { errors: additional_attribute.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def additional_attribute_params
        params.require(:data).require(:attributes).permit(:attribute_name, :long_text)
      end
    end
  end
end
