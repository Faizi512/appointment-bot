desc 'To add parts authority products matching with solidus products'
task parts_authority: :environment do
  store = Store.find_by(store_id: 'parts_authority')
  itemFoundCount = 0
  itemNotFoundCount = 0
  PartAuthorityProduct.all.each do |row|
    product_line = row["product_line"]
    part_number = row["part_number"]
    if(isItemPresent(product_line, part_number))
      itemFoundCount += 1
      product = PartAuthorityProduct.where(product_line: product_line, part_number: part_number)
      title = product[0][:product_line]
      mpn = product[0][:part_number]
      brand = PartAuthorityBrand.where(product_line: product_line)[0][:brand_name]
      price = product[0][:price]
      # core_price = product[0][:core_price]
      qty = product[0][:qty_on_hand]
      # v_qty = product[0][:vendor_qty_on_hand]
      # packs = product[0][:packs]
      puts "#{itemFoundCount}: product_line: #{title}, part_number: #{mpn}, name: #{brand}, price: #{price}, inventory_quantity: #{qty}"
      add_parts_authority_products_to_store(store, title, brand, mpn, qty, price)
    else
      itemNotFoundCount += 1
    end
  end
  puts "============================================"
  puts "Total products in catalog: #{itemFoundCount+itemNotFoundCount}"
  puts "Total items found in solidus: #{itemFoundCount}"
  puts "Total items not found in solidus: #{itemNotFoundCount}"
  puts "============================================"
end

def isItemPresent(product_line, part_number)
  if(PartAuthorityBrand.where(product_line: product_line).present?)
    name = PartAuthorityBrand.where(product_line: product_line)[0][:brand_name]
  end
  if(PartAuthorityBrandsMpn.where(brand: name, mpn: part_number).present? )
    return true
  end
  return false
end

def add_parts_authority_products_to_store(store, title, brand, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
end