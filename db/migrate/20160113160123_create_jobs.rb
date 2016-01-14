class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name, null: false
      t.integer :format, null: false
      t.string :file, null: false
      t.integer :format_export
      t.string :file_md5, null: false
      t.integer :status, null: false, default: 0

      t.timestamps null: false
    end
  end
end