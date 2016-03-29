class AddFilenameToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :filename, :string, null: false, default: ''
  end
end
