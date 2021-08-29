class CreateLoadBoards < ActiveRecord::Migration[6.1]
  def change
    create_table :load_boards do |t|
      t.string :name, unique: true

      t.timestamps
    end
  end
end
