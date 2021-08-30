class AddDismissedAtToLoad < ActiveRecord::Migration[6.1]
  def change
    add_column :loads, :dismissed_at, :timestamp
  end
end
