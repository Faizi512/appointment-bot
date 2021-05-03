desc  'To add APR data in archive table from CSV file.'
task apr_holly_performance: :environment do
    store = Store.find_by(name: 'holly_performance')
    file = Curb.open_uri(store.href)
    rows = CSV.read(file.path, headers: true, header_converters: :symbol)
    rows.each do |row|
      brand = row[:brand]
      mpn = row[:item]
      qty = row[:availible_today]
      price = row[:map_price].to_i
      title = row[:description]
      if brand == 'APR'
        # add_holly_performance_products_to_store(store, title, brand, mpn, qty, price)
        puts "Title= #{title}"
        puts "Brand=#{brand} MPN=#{mpn} qty=#{qty} price=#{price}"
      end
    end
end

def add_holly_performance_products_to_store(store, title, brand, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
end