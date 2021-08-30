class AddEquipmentTypeCodeToLoad < ActiveRecord::Migration[6.1]
  def change
    add_column :loads, :equipment_type_code, :string
  end
end
