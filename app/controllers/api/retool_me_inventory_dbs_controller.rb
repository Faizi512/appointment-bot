module Api
  class RetoolMeInventoryDbsController < ApplicationController
    protect_from_forgery except: :update

    def update
      if params.present?
        params[:Key1].each do |rec|
          product = MeInventoryDB.find_or_create_by(id: rec[:id])
          product.update(brand: rec[:brand], product_name: rec[:product_name], sku: rec[:sku], cost: rec[:cost], qty: rec[:qty], loc: rec[:loc], stock_state: rec[:stock_state]) if product.present?
        end
      end
      render json: 'success'.to_json, status: :ok
    end

    def add_inventory
      purchase_order = MePurchaseOrder.find_by(sku: params[:sku])
      if purchase_order.present?
        qty = purchase_order.qty - params[:qty].to_i
        qty <= 0 ? purchase_order.delete : purchase_order.update(qty: qty)
      end

      if params[:sku].present?
        inventory_item = MeInventoryDB.find_or_create_by(sku: params[:sku])
        qty = inventory_item.qty.nil? ? 0 : inventory_item.qty
        inventory_item.update(qty: (params[:qty].to_i + qty), brand: params[:brand], product_name: params[:product_name], mpn: params[:mpn])
      end

      render json: 'success'.to_json, status: :ok
    end
  end
  # end class
end
# end module
