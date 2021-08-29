class AddBrokerCompanyIdentifierToLoad < ActiveRecord::Migration[6.1]
  def change
    add_reference :loads, :broker_company, null: false, foreign_key: true
  end
end
