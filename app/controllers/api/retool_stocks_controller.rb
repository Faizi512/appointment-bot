module Api
  class RetoolStocksController < ApplicationController
    protect_from_forgery except: :update
    def update
      if params.present?
        process_stock_ids = []
        params[:Key1].each do |stock|
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
            store_id = Store.find_by(name:"turn14").id
          elsif stock[:stock_location_name] == "Integrated Engineering"
            store_id = Store.find_by(name:"performancebyie").id
          end
          
          product = LatestProduct.where(store_id: store_id).find_by(sku: stock[:variant_sku])
          if product.present?
            data1[:count_on_hand] = product.inventory_quantity
            # data2 = {t14_inventory: product.inventory_quantity}
            # data1.merge!(data2)
          end
        
          db_stock = RetoolStock.find_or_create_by(variant_id: stock[:variant_id],variant_sku: stock[:variant_sku])
          db_stock.update(data1)
          process_stock_ids << db_stock.id
        end
        RetoolStock.where.not(id: process_stock_ids).delete_all
      end
      render json: "success".to_json, status: :ok
    end

  end
end