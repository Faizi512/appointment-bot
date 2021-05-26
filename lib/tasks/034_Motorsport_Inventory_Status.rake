require "google_drive"
require "roo"
desc 'To scrape products of 034 Motorsport from google spreadsheet file using google_drive gem'
task motorsport_inventory: :environment do
    store = Store.find_by(name: 'motorsport')
    count = 0
    session = GoogleDrive::Session.from_config("#{Rails.root}/lib/tasks/config.json")
    ws = session.spreadsheet_by_key("#{ENV['MOTORSPORT_SPREADSHEET_ID']}").worksheets[0]
    ws.rows.each do |row|
        if(count == 0)
            count += 1
        else
            mpn = row[0]
            product_title = row[1]
            qty= row[2]
            count = count + 1
            add_034_motorsport_products_to_store(store, product_title, mpn, qty)
            puts "#{count}:\t #{mpn},\t\t #{product_title},\t\t #{qty}"
        end
    end
end

def add_034_motorsport_products_to_store(store, title, mpn, qty)
    latest = store.latest_products.find_or_create_by(mpn: mpn)
    latest.update(product_title: title, brand: 'Motorsport', mpn: mpn, inventory_quantity: qty)
    latest.archive_products.create(store_id: store.id, product_title: title, brand: 'Neuspeed', mpn: mpn, inventory_quantity: qty)
end
