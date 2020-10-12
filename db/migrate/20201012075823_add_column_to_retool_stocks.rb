class AddColumnToRetoolStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :retool_stocks, :mfr_stock, :string
    add_column :retool_stocks, :mfr_esd, :string
  end
end
