class CreateTurn14Tokens < ActiveRecord::Migration[5.1]
  def up
    create_table :turn14_tokens do |t|
      t.json :token

      t.timestamps
    end
  end
end
