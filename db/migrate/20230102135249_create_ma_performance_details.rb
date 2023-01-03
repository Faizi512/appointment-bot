class CreateMaPerformanceDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :ma_performance_details do |t|
      t.string :variant_id
      t.text :description
      t.text :features
      t.text :benefits
      t.text :included
      t.string :variant_href

      t.timestamps
    end
  end
end
