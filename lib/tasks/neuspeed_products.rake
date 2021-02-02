require 'roo'
desc 'To scrape products of neuspeed from dropbox xlsx file'
task neuspeed_products: :environment do
  store = Store.find_by(name: 'neuspeed')
  data = Roo::Spreadsheet.open(ENV['NEUSPEED_DROPBOX_URL'], extension: :xlsx)
  data.each_with_index do |row, index|
    next if index.zero?

    mpn = row[0]
    title = row[1].concat(' ').concat(row[2])
    qty = row[3]
    add_neuspeed_products_to_store(store, title, mpn, qty)
  end
end

def add_neuspeed_products_to_store(store, title, mpn, qty)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: 'Neuspeed', mpn: mpn, inventory_quantity: qty)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: 'Neuspeed', mpn: mpn, inventory_quantity: qty)
end
