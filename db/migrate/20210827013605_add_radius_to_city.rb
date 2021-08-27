class AddRadiusToCity < ActiveRecord::Migration[6.1]
  def change
    add_column :cities, :radius, :integer
  end
end
