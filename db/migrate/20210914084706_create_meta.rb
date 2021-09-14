class CreateMeta < ActiveRecord::Migration[6.1]
  def change
    create_table :meta do |t|
      t.string :key, null: false, unique: true
      t.json :value, null: false

      t.timestamps
    end
  end
end
