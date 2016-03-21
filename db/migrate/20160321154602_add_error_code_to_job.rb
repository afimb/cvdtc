class AddErrorCodeToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :error_code, :string
  end
end
