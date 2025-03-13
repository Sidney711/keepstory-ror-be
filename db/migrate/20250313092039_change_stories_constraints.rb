class ChangeStoriesConstraints < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE stories SET is_date_approx = FALSE WHERE is_date_approx IS NULL"

    change_column :stories, :title, :string, limit: 255, null: false

    change_column :stories, :content, :text, null: false

    change_column :stories, :is_date_approx, :boolean, null: false, default: false
  end

  def down
    change_column :stories, :title, :string, limit: 255, null: true
    change_column :stories, :content, :text, null: true
    change_column :stories, :is_date_approx, :boolean, null: true, default: nil
  end
end
