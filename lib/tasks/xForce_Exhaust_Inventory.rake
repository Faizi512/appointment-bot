desc 'To scrap inventory from xForce using 3PL Central REST API'
task :xForce_Inventory => :environment do
    xForce_token = Curb.get_x_force_token("#{ENV['X_FORCE_API']}/AuthServer/api/Token")
    inventory_url = "#{ENV['X_FORCE_API']}/inventory?pgsiz=1000"
    inventory = Curb.make_get_request(inventory_url , xForce_token["access_token"])
    store = Store.find_by(name: 'xforce')
    inventory["ResourceList"].each do |item|
        mpn     = item['ItemIdentifier']['Sku']
        brand   = 'XForce'
        qty     = item['OnHandQty']
        title   = item['ItemDescription']
        p_id    = item['ReceiveItemId']
        puts "product_id: #{p_id} mpn: #{mpn} brand: #{brand} product title: #{title} inventory_quantity: #{qty}"
        add_XForce_products_to_store(store, title, brand, mpn, qty, p_id)
    end
end


def add_XForce_products_to_store(store, title, brand, mpn, qty, p_id)
    latest = store.latest_products.find_or_create_by(mpn: mpn)
    latest.update(product_title: title, brand: brand, mpn: mpn, inventory_quantity: (latest.inventory_quantity.to_i + qty.to_i).to_s,  product_id: p_id)
    latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, product_id: p_id)
end