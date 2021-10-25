desc 'To add parts authority products matching with solidus products'
task parts_authority: :environment do
  begin
    @product_line = ""
    store = Store.find_by(name: 'Parts Authority')
    itemFoundCount = 0
    itemNotFoundCount = 0
    PartAuthorityBrandsMpn.all.each do |row|
      brand_name = row["brand"]
      mpn = row["mpn"]
      if(isItemPresent(brand_name, mpn))
        itemFoundCount += 1
        product = PartAuthorityProduct.where(product_line: @product_line, part_number: mpn)
        title = product[0][:product_line]
        mpn = product[0][:part_number]
        brand = PartAuthorityBrand.where(product_line: @product_line)[0][:brand_name]
        price = product[0][:price]
        qty = product[0][:qty_on_hand]
        puts "#{itemFoundCount}: product_line: #{title}, part_number: #{mpn}, name: #{brand}, price: #{price}, inventory_quantity: #{qty}"
        add_parts_authority_products_to_store(store, title, brand, mpn, qty, price)
      else
        itemNotFoundCount += 1
      end
    end
    raise Exception.new "Data not found" if (itemFoundCount+itemNotFoundCount) == 0
    puts "============================================"
    puts "Total items in solidus: #{itemFoundCount+itemNotFoundCount}"
    puts "Total items found in solidus: #{itemFoundCount}"
    puts "Total items not found in solidus: #{itemNotFoundCount}"
    puts "============================================"
  rescue Exception => e
    puts e.message
    UserMailer.with(user: e, script: "parts_authority").issue_in_script.deliver_now
  end
end

def isItemPresent(brand_name, mpn)
  if(PartAuthorityBrand.where(brand_name: brand_name).present?)
    @product_line = PartAuthorityBrand.where(brand_name: brand_name)[0][:product_line]
  end
  if(PartAuthorityProduct.where(product_line: @product_line, part_number: mpn).present?)
    return true
  end
  return false
end

def add_parts_authority_products_to_store(store, title, brand, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
end