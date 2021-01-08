module Api
  class RetoolMePurchaseOrdersController < ApplicationController
    protect_from_forgery except: :update

    def update
      if params.present?
        params[:Key1].each do |rec|
          product = MePurchaseOrder.find_or_create_by(id: rec[:id])
          next if product.blank?

          product.update(modded_po: rec[:modded_po], vendor: rec[:vendor], vendor_po: rec[:vendor_po],
          brand: rec[:brand], product_name: rec[:product_name], mpn: rec[:mpn], sku: rec[:sku], qty: rec[:qty],
          cost: rec[:cost], shipping_eta: rec[:shipping_eta], tracking: rec[:tracking], stock_state: rec[:stock_state])
        end
      end
      render json: 'success'.to_json, status: :ok
    end

    def update_tracking
      orders = MePurchaseOrder.where(modded_po: params[:modded_po]) if params.present?
      orders.update(tracking: params[:tracking]) if orders.present?
      render json: 'success'.to_json, status: :ok
    end

    def add_purchase_order
      MePurchaseOrder.create(modded_po: params[:modded_po], vendor: params[:vendor], vendor_po: params[:vendor_po],
          brand: params[:brand], product_name: params[:product_name], mpn: params[:mpn], sku: params[:sku], qty: params[:qty],
          cost: params[:cost], shipping_eta: params[:shipping_eta], tracking: params[:tracking])
      if params[:sku].present?
        inventory_item = MeInventoryDB.find_or_create_by(sku: params[:sku])
        qty = inventory_item.qty == nil ? 0 : inventory_item.qty 
        inventory_item.update(qty: (params[:qty].to_i + qty), brand: params[:brand], product_name: params[:product_name], mpn: params[:mpn])
      end
    end
    # write new method here
  end
  # end class
end
# end module