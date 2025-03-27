class ChangeSchoolNameNullConstraintInEducations < ActiveRecord::Migration[8.0]
  def up
    Education.where(school_name: nil).update_all(school_name: '-')
    change_column_null :educations, :school_name, false
  end

  def down
    change_column_null :educations, :school_name, true
  end
end