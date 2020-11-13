module Api
  class RetoolMeNewProductsController < ApplicationController
    protect_from_forgery except: :update

    def update
      if params.present?
        params[:Key1].each do |rec|
          product = MeNewProduct.find_or_create_by(fcpeuro_id: rec[:fcpeuro_id])
          product.update(product_name: rec[:product_name], sku: rec[:sku], mpn: rec[:mpn], retail: rec[:retail], price: rec[:price], cost: rec[:cost]) if product.present?
        end
      end
      render json: 'success'.to_json, status: :ok
    end

    def add_product
      product = MeNewProduct.find_or_create_by(fcpeuro_id: params[:fcpeuro_id]) if params.present?
      product.update(status: 'Added') if product.present?
      render json: 'success'.to_json, status: :ok
    end

  end
  # end class
end
# end module
