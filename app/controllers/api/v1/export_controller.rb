class Api::V1::ExportController < ApplicationController
  before_action :authenticate

  def family_member
    current_family = Family.where(account_id: current_account.id).first
    family_member = FamilyMember.find_by(id: params[:id], family_id: current_family.id)

    if params[:language] == "cs"
      ExportFamilyMemberCsJob.perform_later(family_member.id)
    else
      ExportFamilyMemberEnJob.perform_later(family_member.id)
    end

    render json: { message: "Export PDF byl zařazen do fronty." }, status: :accepted
  end

  def family
    current_family = Family.where(account_id: current_account.id).first

    if params[:language] == "cs"
      ExportFamilyCsJob.perform_later(current_family.id)
    else
      ExportFamilyEnJob.perform_later(current_family.id)
    end

    render json: { message: "Export PDF byl zařazen do fronty." }, status: :accepted
  end

  def family_tree
    current_family = Family.where(account_id: current_account.id).first
    family_member = FamilyMember.find_by(id: params[:id], family_id: current_family.id)
    ExportFamilyTreeJob.perform_later(family_member.id, params[:language])
    render json: { message: "Export PDF byl zařazen do fronty." }, status: :accepted
  end
end
