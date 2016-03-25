class AddFileSizeToStat < ActiveRecord::Migration
  def change
    add_column :stats, :file_size, :decimal, precision: 5, scale: 2
  end
end
