class Api::V1::FamilyMembersController < ApplicationController
  before_action :authenticate

  def create
    resource = FamilyMember.new(resource_params)

    resource.family = Family.where(account_id: current_account.id).first

    if resource.save
      render json: resource, status: :created
    else
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  def update_profile_picture
    resource = FamilyMember.find(params[:id])
    file = params.dig(:data, :attributes, :profile_picture)
    if file.present?
      resource.profile_picture.attach(file)
      if resource.profile_picture.attached?
        render json: { profile_picture_url: rails_blob_url(resource.profile_picture, only_path: true) }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["No profile picture provided"] }, status: :unprocessable_entity
    end
  end

  def delete_profile_picture
    resource = FamilyMember.find(params[:id])
    if resource.profile_picture.attached?
      resource.profile_picture.purge
      head :no_content
    else
      render json: { errors: ["No profile picture attached"] }, status: :unprocessable_entity
    end
  end

  protected

  def create_resource(object, context)
    family = Family.where(account_id: current_account.id).first

    if family && object.respond_to?(:family=)
      object.family = family
    end

    super
  end

  private

  def resource_params
    params.require(:data).require(:attributes).permit(:first_name, :last_name, :date_of_birth, :date_of_death)
  end
end
