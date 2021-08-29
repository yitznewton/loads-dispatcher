class CreateLoadIdentifiers < ActiveRecord::Migration[6.1]
  def change
    create_table :load_identifiers do |t|
      t.string :identifier
      t.references :load_board, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :loads, :load_identifier, null: false, foreign_key: { on_delete: :cascade }
  end
end
