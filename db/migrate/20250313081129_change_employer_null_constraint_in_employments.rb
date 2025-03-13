class ChangeEmployerNullConstraintInEmployments < ActiveRecord::Migration[8.0]
  def up
    Employment.where(employer: nil).update_all(employer: '-')
    change_column_null :employments, :employer, false
  end

  def down
    change_column_null :employments, :employer, true
  end
end
