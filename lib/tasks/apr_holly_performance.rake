desc  'To add APR data in archive table from CSV file.'
task apr_holly_performance: :environment do
  begin
    store = Store.find_by(name: 'holly_performance')
    file = Curb.open_uri(store.href)
    rows = CSV.read(file.path, headers: true, header_converters: :symbol)
    raise Exception.new "Error: 'Data not found', error found in 'apr_holly_performance' script" if !rows.present?
    rows.each do |row|
      brand = row[:brand]
      mpn = row[:item]
      qty = row[:available_today]
      price = row[:map_price].to_i
      title = row[:description]
      if brand == 'APR' || brand == "Dinan"
        add_holly_performance_products_to_store(store, title, brand, mpn, qty, price)
        puts "Title= #{title}"
        puts "Brand=#{brand} MPN=#{mpn} qty=#{qty} price=#{price}"
      end
    end
  rescue Exception => e
    puts e.message
    UserMailer.with(user: e, script: "apr_holly_performance").issue_in_script.deliver_now
  end
end

def add_holly_performance_products_to_store(store, title, brand, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
end