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

  end
  # end class
end
# end module