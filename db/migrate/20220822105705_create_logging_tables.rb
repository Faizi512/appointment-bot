class CreateLoggingTables < ActiveRecord::Migration[5.1]
  def change
    create_table :logging_tables do |t|
      t.references :store, foreign_key: true
      t.string :url
      t.integer :page_number
      t.integer :offset

      t.timestamps
    end
  end
end
