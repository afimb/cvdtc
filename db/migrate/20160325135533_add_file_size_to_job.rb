class AddFileSizeToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :file_size, :decimal, precision: 5, scale: 2
  end
end
