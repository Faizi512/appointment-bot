class ChangeContractedDateToBeDatetimeInRetoolOrders < ActiveRecord::Migration[5.1]
  def up
	  change_column :retool_orders, :contracted_date, :datetime
	end

	def down
	  change_column :retool_orders, :contracted_date, :date
	end
end
