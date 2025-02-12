class CreateStories < ActiveRecord::Migration[8.0]
  def change
    create_table :stories do |t|
      t.string :title
      t.text :content
      t.string :date_type
      t.date :story_date
      t.integer :story_year
      t.boolean :is_date_approx
      t.references :family, null: false, foreign_key: true

      t.timestamps
    end
  end
end
