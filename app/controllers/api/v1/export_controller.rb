class Api::V1::ExportController < ApplicationController
  before_action :authenticate

  def family_member
    current_family = Family.where(account_id: current_account.id).first
    family_member = FamilyMember.find_by(id: params[:id], family_id: current_family.id)
    ExportFamilyMemberJob.perform_later(family_member.id)
    render json: { message: "Export PDF byl zařazen do fronty." }, status: :accepted
  end

  def family
    current_family = Family.where(account_id: current_account.id).first
    ExportFamilyJob.perform_later(current_family.id)
    render json: { message: "Export PDF byl zařazen do fronty." }, status: :accepted
  end
end
