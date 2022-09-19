class Turn14Product < ApplicationRecord
  belongs_to :supplier
  has_one :manufacturer, dependent: :destroy
  has_many :latest_purchase_orders, dependent: :destroy
  has_many :archived_purchase_orders, dependent: :destroy

  def self.add_t14_product(supplier, item_id, product_name, part_number, mfr_part_number, brand_id, brand, active, regular_stock, not_carb_approved, alternate_part_number, barcode, prop_65, epa, part_description, category, subcategory, dim_box_number, dim_length, dim_width, dim_height, dim_weight, carb_eo_number, clearance_item, thumbnail, units_per_sku)
    product = supplier.turn14_products.find_or_create_by(supplier_id: supplier.id, item_id: item_id)
    product.update(part_number: part_number, name: product_name, mfr_part_number: mfr_part_number, brand_id: brand_id, brand: brand, active: active, regular_stock: regular_stock, not_carb_approved: not_carb_approved, alternate_part_number: alternate_part_number, barcode: barcode, prop_65: prop_65, epa: epa, part_description: part_description, category: category, subcategory: subcategory, dim_box_number: dim_box_number, dim_length: dim_length, dim_width: dim_width, dim_height: dim_height, dim_weight: dim_weight, carb_eo_number: carb_eo_number, clearence_item: clearance_item, thumbnail: thumbnail, units_per_sku: units_per_sku)
    product
  end

  def add_manufacturer(product, stock, esd)
    if product.manufacturer.nil?
      product.create_manufacturer(stock: stock, esd: esd)
    else
      product.manufacturer.update(stock: stock, esd: esd)
    end
    puts 'Manufacturer added.'
  end

  def add_latest_purchase_order(product, eta)
    if eta['qty_on_order'].present?
      eta['qty_on_order'].each do |location|
        product.latest_purchase_orders.find_or_create_by(
          location: location[0],
          qty_on_order: location[1],
          estimated_availability: eta['estimated_availability'][location[0].to_s]
        )
        puts 'Latest purchase order added.'
      end
    end
  end

  def add_archived_purchase_order(product, eta)
    if eta['qty_on_order'].present?
      eta['qty_on_order'].each do |location|
        product.archived_purchase_orders.create!(
          location: location[0],
          qty_on_order: location[1],
          estimated_availability: eta['estimated_availability'][location[0].to_s]
        )
        puts 'Archived purchase order added.'
      end
    end
  end
end
