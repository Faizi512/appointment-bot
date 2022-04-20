class CreateCspracinglogs < ActiveRecord::Migration[5.1]
  def change
    create_table :cspracinglogs do |t|
      t.string  :offset
      t.timestamps
    end
  end
end
