module Api
  class RetoolMeNewProductsController < ApplicationController
    protect_from_forgery except: :update

    def update
      if params.present?
        params[:Key1].each do |rec|
          update_product(rec)
        end
      end
      render json: 'success'.to_json, status: :ok
    end

    def add_product
      update_product(params) if params.present?
      render json: 'success'.to_json, status: :ok
    end

    def update_product(rec)
      product = MeNewProduct.find_or_create_by(fcpeuro_id: rec[:fcpeuro_id])
      product.update(product_name: rec[:product_name], sku: rec[:sku], mpn: rec[:mpn], retail: rec[:retail], price: rec[:price], cost: rec[:cost]) if product.present?
    end
  end
  # end class
end
# end module
