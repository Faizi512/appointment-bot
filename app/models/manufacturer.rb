class Manufacturer < ApplicationRecord
  belongs_to :turn14_product

  def self.add_manufacturer(product, stock, esd)
    if product.manufacturer.nil?
      product.create_manufacturer(stock: stock, esd: esd)
    else
      product.manufacturer.update(stock: stock, esd: esd)
    end
  end
end
