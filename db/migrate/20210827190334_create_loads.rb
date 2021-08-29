class CreateLoads < ActiveRecord::Migration[6.1]
  def change
    create_table :loads do |t|
      t.integer :weight, null: false
      t.integer :length
      t.integer :distance, null: false
      t.integer :rate
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email
      t.string :reference_number
      t.timestamp :pickup_date, null: false
      t.timestamp :dropoff_date
      t.json :pickup_location, null: false
      t.json :dropoff_location, null: false
      t.string :broker_company, null: false
      t.text :notes
      t.json :other

      t.timestamps
    end
  end
end
