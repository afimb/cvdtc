class AddShortUrlToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :short_url, :string
  end
end
