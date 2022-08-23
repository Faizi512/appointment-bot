class AddLastPageToLoggingTable < ActiveRecord::Migration[5.1]
  def change
    add_column :logging_tables, :last_page, :bool
  end
end
