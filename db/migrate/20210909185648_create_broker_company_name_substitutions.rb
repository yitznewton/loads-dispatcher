class CreateBrokerCompanyNameSubstitutions < ActiveRecord::Migration[6.1]
  def change
    create_table :broker_company_name_substitutions do |t|
      t.string :before, null: false
      t.string :after, null: false

      t.timestamps
    end
  end
end
