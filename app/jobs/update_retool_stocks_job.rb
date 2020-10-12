class UpdateRetoolStocksJob < ApplicationJob
  queue_as :default
  before_enqueue :t14_products
  before_enqueue :ie_products

  def perform(records)
    process_stock_ids = []
    sym = 'Key1'
    location = records[sym.to_sym].first[:stock_location_name]
    available_on = records[sym.to_sym].first[:product_available_on]
    records[sym.to_sym].each do |stock|
      data = data_hash(stock)
      product = get_product(location, stock[:variant_sku], stock[:variant_mpn])
      if product.present?
        data[:count_on_hand] = product.inventory_quantity
        product = Turn14Product.find_by(item_id: product['sku'])
        if product.present? && product.manufacturer.present?
          data1 = { mfr_stock: product.manufacturer['stock'], mfr_esd: product.manufacturer['esd'] }
          data.merge!(data1)
        end
      else
        next
      end
      db_stock = RetoolStock.find_or_create_by(variant_id: stock[:variant_id], variant_sku: stock[:variant_sku])
      db_stock.update(data)
      process_stock_ids << db_stock.id
    end
    remove_records(process_stock_ids, location, available_on)
  end
end

def t14_products
  LatestProduct.where(store_id: Store.find_by(name: 'turn14').id)
end

def ie_products
  # ie_products means Integrated Engineering products coming from performancebyie
  LatestProduct.where(store_id: Store.find_by(name: 'performancebyie').id)
end

def data_hash stock
  {
    variant_id:           stock[:variant_id],
    variant_name:         stock[:variant_name],
    variant_sku:          stock[:variant_sku],
    variant_mpn:          stock[:variant_mpn],
    count_on_hand:        stock[:count_on_hand],
    product_id:           stock[:product_id],
    product_name:         stock[:product_name],
    product_available_on: stock[:product_available_on],
    stock_location_name:  stock[:stock_location_name],
    brand_name:           stock[:brand_name]
  }
end

def get_product location, sku, mpn
  if location == 'Turn 14'
    t14_products.find_by(sku: sku)
  elsif location == 'Integrated Engineering'
    ie_products.find_by(sku: mpn)
  end
end

def remove_records ids, location, available_on
  data = RetoolStock.where(stock_location_name: location)
  if location == 'Turn 14'
    if available_on.nil? || available_on >= DateTime.now
      data = data.where('product_available_on >= ? OR product_available_on = ?', DateTime.now, nil)
    elsif available_on.present? || available_on <= DateTime.now
      data = data.where('product_available_on <= ? OR product_available_on != ?', DateTime.now, nil)
    end
  end
  data.where.not(id: ids).delete_all
end
