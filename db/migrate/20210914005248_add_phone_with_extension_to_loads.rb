class AddPhoneWithExtensionToLoads < ActiveRecord::Migration[6.1]
  def change
    add_column :loads, :contact_phone_extension, :string
  end
end
