class CreateBrokerCompanyIdentifiers < ActiveRecord::Migration[6.1]
  def change
    create_table :broker_company_identifiers do |t|
      t.string :identifier
      t.references :broker_company, null: false, foreign_key: true
      t.references :load_board, null: false, foreign_key: true

      t.timestamps
    end
  end
end
