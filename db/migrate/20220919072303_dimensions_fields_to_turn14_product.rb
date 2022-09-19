class DimensionsFieldsToTurn14Product < ActiveRecord::Migration[5.1]
  def change
    add_column :turn14_products, :dim_box_number, :integer 
    add_column :turn14_products, :dim_length, :float
    add_column :turn14_products, :dim_width, :float
    add_column :turn14_products, :dim_height, :float 
    add_column :turn14_products, :dim_weight, :float
  end
end
