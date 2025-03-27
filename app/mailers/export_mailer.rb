class ExportMailer < ApplicationMailer
  def export_member_ready_cs_email(family_member)
    @family_member = family_member
    @account = Account.find(@family_member.family.account_id)
    mail(to: @account.email, subject: "Export člena #{@family_member.first_name} #{@family_member.last_name} je hotový")
  end

  def export_family_ready_cs_email(family)
    @family = family
    @account = Account.find(family.account_id)
    mail(to: @account.email, subject: "Export rodiny je hotový")
  end

  def export_family_tree_ready_cs_email(family_member)
    @family_member = family_member
    @account = Account.find(@family_member.family.account_id)
    mail(to: @account.email, subject: "Export rodokmenu člena #{@family_member.first_name} #{@family_member.last_name} je hotový")
  end

  def export_member_ready_en_email(family_member)
    @family_member = family_member
    @account = Account.find(@family_member.family.account_id)
    mail(to: @account.email, subject: "Export of member #{@family_member.first_name} #{@family_member.last_name} is ready")
  end

  def export_family_ready_en_email(family)
    @family = family
    @account = Account.find(family.account_id)
    mail(to: @account.email, subject: "Family export is ready")
  end

  def export_family_tree_ready_en_email(family_member)
    @family_member = family_member
    @account = Account.find(@family_member.family.account_id)
    mail(to: @account.email, subject: "Family tree export for member #{@family_member.first_name} #{@family_member.last_name} is ready")
  end

end
