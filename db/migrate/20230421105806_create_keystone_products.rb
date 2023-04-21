class CreateKeystoneProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :keystone_products do |t|
      t.string :vendor_name
      t.string :vcpn
      t.string :vendor_code
      t.string :part_number
      t.string :manufacturer_part_no
      t.string :long_description
      t.string :jobber_price
      t.string :cost
      t.string :ups_able
      t.string :core_charge
      t.integer :case_qty
      t.string :is_non_returnable
      t.string :upc_code
      t.integer :total_qty
      t.string :kit_components
      t.string :is_kit

      t.timestamps
    end
  end
end
