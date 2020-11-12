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
      if params.present?
        # byebug
        puts 'add product code here'
      end
      render json: 'success'.to_json, status: :ok
    end

    #  def data_hash rec
    #   {
    #  		brand: rec[:brand],
    #      brand_id: rec[:brand_id],
    #      product_name: rec[:product_name],
    #      slug: rec[:slug],
    #      sku: rec[:sku],
    #      price: rec[:price],
    #      cost: rec[:cost],
    #      retail: rec[:retail],
    #      mpn: rec[:mpn],
    #      taxon_ids: rec[:taxon_ids],
    #      taxon_name: rec[:taxon_name],
    #      fcpeuro_id: rec[:fcpeuro_id],
    #      fcpeuro_productsid: rec[:fcpeuro_productsid],
    #      fcpeuro_quality: rec[:fcpeuro_quality],
    #      fcpeuro_oenumbers: rec[:fcpeuro_oenumbers],
    #      fcpeuro_mfgnumbers: rec[:fcpeuro_mfgnumbers]
    #    }
    # end
  end
  # end class
end
# end module
