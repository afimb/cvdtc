class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name, null: false
      t.integer :iev_action, null: false, default: 0
      t.integer :format, null: false
      t.string :file
      t.string :url
      t.integer :format_convert
      t.string :file_md5
      t.integer :status, null: false, default: 0
      t.string :prefix
      t.string :time_zone
      t.integer :max_distance_for_commercial, null: false, default: 0
      t.boolean :ignore_last_word, null: false, default: false
      t.integer :ignore_end_chars, null: false, default: 0
      t.integer :max_distance_for_connection_link, null: false, default: 0

      t.timestamps null: false
    end
  end
end
