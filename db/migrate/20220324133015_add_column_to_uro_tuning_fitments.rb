class AddColumnToUroTuningFitments < ActiveRecord::Migration[5.1]
  def change
    add_column :uro_tuning_fitments, :product_id, :string
  end
end
