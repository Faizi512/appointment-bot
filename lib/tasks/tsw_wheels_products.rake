desc 'To scrape tsw wheels products reading CSV through api'
task tsw_wheels_products: :environment do
	store = Store.find_by(name: 'tsw_wheels')
  file = Curb.open_uri(store.href)
  rows = CSV.read(file.path,headers: true,header_converters: :symbol, :encoding => 'windows-1251:utf-8')

  rows.each do |row|
    brand = row[:brand]
    title = row[:description]
    mpn = row[:item_number]
    qty = row[:quantity_all_us]
    price = row[:map].to_i
    add_tsw_wheels_products_to_store(store, title, brand, mpn, qty, price)
    puts "Title= #{title}"
    puts "Brand=#{brand} MPN=#{mpn} qty=#{qty} price=#{price}"
  end
end

def add_tsw_wheels_products_to_store(store, title, brand, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, mpn: mpn, inventory_quantity: qty, price: price)
end