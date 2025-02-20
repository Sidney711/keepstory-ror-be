module Api
  module V1
    class MarriagesController < ApplicationController
      before_action :authenticate

      def create
        family = Family.find_by(account_id: current_account.id)
        unless family
          render json: { errors: ["Family was not found."] }, status: :unprocessable_entity and return
        end

        marriage = Marriage.new(marriage_params)
        relationships = params[:data][:relationships] rescue nil

        if relationships && relationships["first_partner"].present? && relationships["second_partner"].present?
          first_partner_id = relationships["first_partner"]["data"]["id"] rescue nil
          second_partner_id = relationships["second_partner"]["data"]["id"] rescue nil

          allowed_ids = family.family_members.where(id: [first_partner_id, second_partner_id]).pluck(:id)
          if allowed_ids.include?(first_partner_id.to_i) && allowed_ids.include?(second_partner_id.to_i)
            marriage.first_partner_id = first_partner_id
            marriage.second_partner_id = second_partner_id
          else
            render json: { errors: ["One or both partners are not allowed."] }, status: :unprocessable_entity and return
          end
        else
          render json: { errors: ["Partners relationships must be provided."] }, status: :unprocessable_entity and return
        end

        if marriage.save
          # Předáme prázdný hash jako kontext
          render json: MarriageResource.new(marriage, {}).as_json, status: :created
        else
          render json: { errors: marriage.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def marriage_params
        params.require(:data).require(:attributes).permit(:period)
      end
    end
  end
end
