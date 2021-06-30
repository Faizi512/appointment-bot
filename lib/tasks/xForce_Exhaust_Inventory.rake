desc 'To scrap inventory from xForce using 3PL Central REST API'
task :xForce_Inventory => :environment do
    xForce_token = Curb.get_x_force_token("#{ENV['X_FORCE_API']}/AuthServer/api/Token")
    inventory_url = "#{ENV['X_FORCE_API']}/inventory?pgsiz=1000"
    inventory = Curb.make_get_request(inventory_url , xForce_token["access_token"])
    store = Store.find_by(name: 'xforce')
    mpnArray = []
    productHash = :null
    inventory["ResourceList"].each do |item|
        mpn     = item['ItemIdentifier']['Sku']
        brand   = 'XForce'
        qty     = item["AvailableQty"]
        title   = item['ItemDescription']
        p_id    = item['ReceiveItemId']
        sumedQty = sumQty(mpn,qty, mpnArray, productHash)
        productHash = {"id"=>p_id, "mpn"=>mpn, "brand"=>brand, "product_title"=>title, "qty"=>sumedQty}
        add_XForce_products_to_store(store, title, brand, mpn, sumedQty, p_id)
    end
    LatestProduct.where(store_id: Store.where(store_id: "xforce").ids[0]).all.order(:mpn).each do |item|
        puts "product_id: #{item[:product_id]}, mpn: #{item[:mpn]}, brand: #{item[:brand]}, inventory_quantity: #{item[:inventory_quantity]}, product_title: #{item[:product_title]}"
        latest = store.latest_products.find_or_create_by(mpn: item[:mpn])
        latest.archive_products.create(store_id: store.id, product_title: item[:product_title], brand: item[:brand], mpn: item[:mpn], inventory_quantity: item[:inventory_quantity], product_id: item[:product_id])
    end
end


def add_XForce_products_to_store(store, title, brand, mpn, qty, p_id)
    latest = store.latest_products.find_or_create_by(mpn: mpn)
    latest.update(product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty,  product_id: p_id)
end

def sumQty(mpn, qty, mpnArray, productHash)
    if(mpnArray.include?(mpn))
        qty += productHash["qty"]
    else
        mpnArray << mpn
    end
    qty
end