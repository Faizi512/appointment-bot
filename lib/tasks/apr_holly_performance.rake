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
      price_data = row[:map_price]
      price = price_data.include?('$') ? '%.2f' % price_data.split('$')[1] : '%.2f' % price_data
      title = row[:description]
      if qty.eql?('0') && (brand == 'APR' || brand == "Dinan")
        atp_date = row[:atp_date]
        add_holly_performance_promise_table(mpn, brand, atp_date)
      else
        atp_date = nil
      end
      
      if brand == 'APR' || brand == "Dinan"
        add_holly_performance_products_to_store(store, title, brand, mpn, qty, price)
        puts "Title= #{title}"
        puts "Brand=#{brand} MPN=#{mpn} qty=#{qty} price=#{price}"
        puts "atp_date= #{atp_date}" if atp_date.present?
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

def add_holly_performance_promise_table(mpn, brand, atp_date)
  HolleyPerformanceAvailablePromise.find_or_create_by(mpn: mpn).update(brand: brand, atp_date: atp_date)
end