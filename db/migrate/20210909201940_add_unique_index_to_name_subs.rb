class AddUniqueIndexToNameSubs < ActiveRecord::Migration[6.1]
  def change
    add_index :broker_company_name_substitutions, :before, unique: true
  end
end
