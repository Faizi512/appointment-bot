class UpdateRetoolStocksJob < ApplicationJob
  queue_as :default

  def perform(records)
    process_stock_ids = []
    t14_products = LatestProduct.where(store_id: Store.find_by(name:"turn14").id)
    ie_products = LatestProduct.where(store_id: Store.find_by(name:"performancebyie").id)
    #ie_products means Integrated Engineering products coming from performancebyie
    records[:Key1].each do |stock|
      data1 = 
        {
          variant_id:           stock[:variant_id],
          variant_name:         stock[:variant_name],
          variant_sku:          stock[:variant_sku],
          variant_mpn:          stock[:variant_mpn],
          count_on_hand:        stock[:count_on_hand],
          product_name:         stock[:product_name],
          product_available_on: stock[:product_available_on],
          stock_location_name:  stock[:stock_location_name],
          brand_name:           stock[:brand_name]
        }

      if stock[:stock_location_name] == "Turn 14"
        product = t14_products.find_by(sku: stock[:variant_sku])
      elsif stock[:stock_location_name] == "Integrated Engineering"
        product = ie_products.find_by(sku: stock[:variant_sku])
      end
      
      if product.present?
        data1[:count_on_hand] = product.inventory_quantity
      end
      
      db_stock = RetoolStock.find_or_create_by(variant_id: stock[:variant_id],variant_sku: stock[:variant_sku])
      db_stock.update(data1)
      process_stock_ids << db_stock.id
    end
    RetoolStock.where.not(id: process_stock_ids).delete_all
  end
end
