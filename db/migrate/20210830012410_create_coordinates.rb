class CreateCoordinates < ActiveRecord::Migration[6.1]
  def change
    create_table :coordinates do |t|
      t.float :latitude
      t.float :longitude
      t.string :name

      t.timestamps
    end
  end
end
