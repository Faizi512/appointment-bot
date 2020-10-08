class Turn14Product < ApplicationRecord
  belongs_to :supplier
  has_one :manufacturer, dependent: :destroy
  has_many :latest_purchase_orders, dependent: :destroy
  has_many :archived_purchase_orders, dependent: :destroy

  def self.add_t14_product(supplier, item_id, product_name, part_number, mfr_part_number, brand_id)
    product = supplier.turn14_products.find_or_create_by(supplier_id: supplier.id, item_id: item_id)
    product.update(part_number: part_number, name: product_name, mfr_part_number: mfr_part_number, brand_id: brand_id)
    product
  end
end
