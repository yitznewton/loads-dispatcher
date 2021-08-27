class CreateCities < ActiveRecord::Migration[6.1]
  def change
    create_table :cities do |t|
      t.string :city, null: false
      t.string :state, limit: 2, null: false
      t.integer :radius, null: false
      t.integer :tql_id
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.string :county, null: false

      t.timestamps
    end
  end
end
