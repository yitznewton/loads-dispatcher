class AddRefreshedAtToLoad < ActiveRecord::Migration[6.1]
  def change
    add_column :loads, :refreshed_at, :datetime
  end
end
