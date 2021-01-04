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
          cost: rec[:cost], shipping_eta: rec[:shipping_eta], tracking: rec[:tracking])
        end
      end
      render json: 'success'.to_json, status: :ok
    end

    def update_tracking
      orders = MePurchaseOrder.where(modded_po: params[:modded_po]) if params.present?
      orders.update(tracking: params[:tracking]) if orders.present?
      render json: 'success'.to_json, status: :ok
    end

    # write new method here
  end
  # end class
end
# end module
