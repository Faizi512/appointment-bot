class Store < ApplicationRecord
  has_many :archive_products, dependent: :destroy
  has_many :latest_products, dependent: :destroy

  def self.t14_itemss_insert_in_latest_and_archieve_table(item_id, brand, mpn, inventory_quantity)
    store = Store.find_by(store_id: 'turn14')
    latest = store.latest_products.find_or_create_by(store_id: store.id, mpn: mpn)
    latest.update(brand: brand, inventory_quantity: inventory_quantity, variant_id: item_id)
    latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, inventory_quantity: inventory_quantity, variant_id: item_id)
  end
end
