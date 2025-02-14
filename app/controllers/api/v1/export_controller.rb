class Api::V1::ExportController < ApplicationController
  include ActionView::Layouts

  append_view_path Rails.root.join("app", "views")

  before_action :authenticate

  def family_member
    family = Family.where(account_id: current_account.id).first
    @family_member = FamilyMember.find_by(id: params[:id], family_id: family.id)
    @stories = @family_member.stories

    html = render_to_string(
      template: "api/v1/export/family_member",
      layout: "pdf",
      formats: [:html]
    )

    pdf = WickedPdf.new.pdf_from_string(html)

    file_path = Rails.root.join("public", "pdfs", "family_member_#{@family_member.id}_stories.pdf")
    FileUtils.mkdir_p(File.dirname(file_path))
    File.open(file_path, 'wb') { |file| file << pdf }

    render json: { message: "PDF vygenerováno a uloženo na #{file_path}" }
  end
end
