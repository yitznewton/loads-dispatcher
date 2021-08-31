class AddShortlistedAtToLoad < ActiveRecord::Migration[6.1]
  def change
    add_column :loads, :shortlisted_at, :timestamp
  end
end
