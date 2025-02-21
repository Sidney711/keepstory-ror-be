class ExportMailer < ApplicationMailer
  def export_member_ready_email(family_member)
    @family_member = family_member
    @account = Account.find(family_member.family.account_id)
    mail(to: @account.email, subject: "Export člena rodiny je hotový")
  end

  def export_family_ready_email(family)
    @family = family
    @account = Account.find(family.account_id)
    mail(to: @account.email, subject: "Export rodiny je hotový")
  end
end
