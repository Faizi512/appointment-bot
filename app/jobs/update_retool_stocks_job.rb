class UpdateRetoolStocksJob < ApplicationJob
  queue_as :default

  def perform(records)
    process_stock_ids = []
    sym = "Key1"
    location = records[sym.to_sym].first[:stock_location_name]
    available_on = records[sym.to_sym].first[:product_available_on]
    t14_products = LatestProduct.where(store_id: Store.find_by(name:"turn14").id)
    ie_products = LatestProduct.where(store_id: Store.find_by(name:"performancebyie").id)
    #ie_products means Integrated Engineering products coming from performancebyie
    records[sym.to_sym].each do |stock|
      data = data_hash(stock)

      if location == "Turn 14"
        product = t14_products.find_by(sku: stock[:variant_sku])
      elsif location == "Integrated Engineering"
        product = ie_products.find_by(sku: stock[:variant_mpn])
      end
      
      if product.present?
        data[:count_on_hand] = product.inventory_quantity
      else
        next
      end
      
      db_stock = RetoolStock.find_or_create_by(variant_id: stock[:variant_id],variant_sku: stock[:variant_sku])
      db_stock.update(data)
      process_stock_ids << db_stock.id
    end
    remove_records(process_stock_ids, location, available_on)
  end
end

def data_hash stock
  data = 
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

def remove_records ids, location, available_on
  if location == "Turn 14"
      data = RetoolStock.where(stock_location_name: location)
      if available_on == nil || available_on >= DateTime.now
        data = data.where("product_available_on >= ? OR product_available_on = ?", DateTime.now,nil)
      elsif available_on != nil || available_on <= DateTime.now
        data = data.where("product_available_on <= ? OR product_available_on != ?", DateTime.now,nil)
      end
    else
      data = RetoolStock.where(stock_location_name: location)
    end
    data.where.not(id: ids).delete_all
end
