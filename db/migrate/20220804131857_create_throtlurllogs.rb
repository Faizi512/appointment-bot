class CreateThrotlurllogs < ActiveRecord::Migration[5.1]
  def change
    create_table :throtlurllogs do |t|
      t.string :offset
      t.timestamps
    end
  end
end
