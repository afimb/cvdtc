class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.string :format
      t.string :format_convert
      t.string :info
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
