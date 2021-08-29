class CreateLoadIdentifiers < ActiveRecord::Migration[6.1]
  def change
    create_table :load_identifiers do |t|
      t.string :identifier
      t.references :load_board, null: false, foreign_key: true
      t.references :load, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
