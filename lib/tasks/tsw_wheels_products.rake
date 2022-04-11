desc 'To scrape tsw wheels products reading CSV through api'
task tsw_wheels_products: :environment do
  begin
    store = Store.find_by(name: 'tsw_wheels')
    file = Curb.open_uri(store.href)
    raise Exception.new "File not accessible" if !file.present?
    rows = CSV.read(file.path,headers: true,header_converters: :symbol, :encoding => 'windows-1251:utf-8')
    raise Exception.new "CSV not found" if !file.present?
    rows.each do |row|
      brand = row[:brand]
      title = row[:description]
      mpn = row[:item_number]
      qty = row[:quantity_all_us]
      price_data = row[:map]
      price = price_data.include?('$') ? '%.2f' % price_data.split('$')[1] : '%.2f' % price_data
      add_tsw_wheels_products_to_store(store, title, brand, mpn, qty, price)
      puts "Title= #{title}"
      puts "Brand=#{brand} MPN=#{mpn} qty=#{qty} price=#{price}"
    end
  rescue SignalException => e
    nil
  rescue Exception => e
    puts e.message
    UserMailer.with(user: e, script: "tuner_price_products").issue_in_script.deliver_now
  end
end

def add_tsw_wheels_products_to_store(store, title, brand, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
end