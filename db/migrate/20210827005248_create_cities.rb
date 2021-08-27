class CreateCities < ActiveRecord::Migration[6.1]
  def change
    create_table :cities do |t|
      t.string :city
      t.string :state, limit: 2
      t.integer :tql_id
      t.float :lat
      t.float :lng
      t.string :county

      t.timestamps
    end
  end
end
