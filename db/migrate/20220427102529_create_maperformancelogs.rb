class CreateMaperformancelogs < ActiveRecord::Migration[5.1]
  def change
    create_table :maperformancelogs do |t|
      t.string :offset
      t.timestamps
    end
  end
end
