module Api
  module V1
    class ResidenceAddressesController < ApplicationController
      before_action :authenticate

      def create
        family = Family.find_by(account_id: current_account.id)
        unless family
          render json: { errors: ["Family was not found."] }, status: :unprocessable_entity and return
        end

        residence_address = ResidenceAddress.new(residence_address_params)
        relationships = params[:data][:relationships] rescue nil

        if relationships && relationships["family_member"].present?
          family_member_id = relationships["family_member"]["data"]["id"] rescue nil
          allowed_ids = family.family_members.where(id: family_member_id).pluck(:id)
          if allowed_ids.include?(family_member_id.to_i)
            residence_address.family_member_id = family_member_id
          else
            render json: { errors: ["Family member is not allowed."] }, status: :unprocessable_entity and return
          end
        else
          render json: { errors: ["Family member relationship must be provided."] }, status: :unprocessable_entity and return
        end

        if residence_address.save
          render json: ResidenceAddressResource.new(residence_address, {}).as_json, status: :created
        else
          render json: { errors: residence_address.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def residence_address_params
        params.require(:data).require(:attributes).permit(:address, :period)
      end
    end
  end
end
