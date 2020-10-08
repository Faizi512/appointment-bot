class LatestPurchaseOrder < ApplicationRecord
  belongs_to :turn14_product

  def self.add_latest_purchase_order(product, eta)
    eta['qty_on_order'].each do |location|
      product.latest_purchase_orders.find_or_create_by(
        location: location[0],
        qty_on_order: location[1],
        estimated_availability: eta['estimated_availability'][location[0].to_s]
      )
      Rails.logger.debug 'latest purchase order added'
    end
  end
end
