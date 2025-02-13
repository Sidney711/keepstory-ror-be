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
