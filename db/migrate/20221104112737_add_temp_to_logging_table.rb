class AddTempToLoggingTable < ActiveRecord::Migration[5.1]
  def change
    add_column :logging_tables, :temp, :string
  end
end
