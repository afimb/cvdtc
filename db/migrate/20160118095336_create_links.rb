class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.references :job, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
