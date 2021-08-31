class CreateRawLoads < ActiveRecord::Migration[6.1]
  def change
    create_table :raw_loads do |t|
      t.json :data
      t.references :load, null: false, foreign_key: true

      t.timestamps
    end
  end
end
