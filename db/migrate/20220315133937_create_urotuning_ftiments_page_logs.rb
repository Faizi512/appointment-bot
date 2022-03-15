class CreateUrotuningFtimentsPageLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :urotuning_ftiments_page_logs do |t|
      t.string  :offset
      t.timestamps
    end
  end
end
