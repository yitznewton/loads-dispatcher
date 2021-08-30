class AddEquipmentTypeToLoad < ActiveRecord::Migration[6.1]
  def change
    add_column :loads, :equipment_type, :string
  end
end
