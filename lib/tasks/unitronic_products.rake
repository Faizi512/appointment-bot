desc 'To scrape unitronic products through api which can be hit once per hour'
task unitronic_products: :environment do
  store = Store.find_by(name: 'unitronic')
  url = "#{store.href}apiKey=#{ENV['UNITRONIC_API_KEY']}&apiPassword=#{ENV['UNITRONIC_PASSWORD']}"
  products = Curb.get(url)
  if products.present?
    products.each do |product|
      mpn = product["partNumber"]
      title = product["description"]
      price = product["retailPrice"]
      qty = product["qtyCA"].to_i + product["qtyUS"].to_i
      add_unitronic_products_to_store(store, title, mpn, qty, price)
      # puts "Product= #{product}"
      # puts "MPN=#{mpn} Title=#{title} Price=#{price} QTY=#{qty}"
      # puts "#######################################################################################"
    end
  end
end
def add_unitronic_products_to_store(store, title, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: 'Unitronic', mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: 'Unitronic', mpn: mpn, inventory_quantity: qty, price: price)
end