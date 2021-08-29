class CreatePlacesDistances < ActiveRecord::Migration[6.1]
  def change
    create_table :places_distances do |t|
      t.string :origin, null: false
      t.string :destination, null: false
      t.integer :distance, null: false

      t.timestamps
    end

    add_index :places_distances, [:origin, :destination], unique: true
  end
end
