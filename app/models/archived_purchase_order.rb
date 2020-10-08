class ArchivedPurchaseOrder < ApplicationRecord
  belongs_to :turn14_product

  def self.add_archived_purchase_order(product, eta)
    eta['qty_on_order'].each do |location|
      product.archived_purchase_orders.create!(
        location: location[0],
        qty_on_order: location[1],
        estimated_availability: eta['estimated_availability'][location[0].to_s]
      )
      Rails.logger.debug 'archived purchase order added'
    end
  end
end
