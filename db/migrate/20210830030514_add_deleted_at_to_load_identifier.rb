class AddDeletedAtToLoadIdentifier < ActiveRecord::Migration[6.1]
  def change
    add_column :load_identifiers, :deleted_at, :timestamp
  end
end
