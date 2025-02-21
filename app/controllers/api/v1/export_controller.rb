class Api::V1::ExportController < ApplicationController
  before_action :authenticate

  def family_member
    family_member = FamilyMember.find(params[:id])
    ExportFamilyMemberJob.perform_later(family_member.id)
    render json: { message: "Export PDF byl zařazen do fronty." }, status: :accepted
  end
end
