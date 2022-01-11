class CreateLastVisitedPages < ActiveRecord::Migration[5.1]
  def change
    create_table :last_visited_pages do |t|
      t.string :section
      t.string :url

      t.timestamps
    end
  end
end
