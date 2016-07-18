class AddParametersToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :parameters, :text
  end
end
