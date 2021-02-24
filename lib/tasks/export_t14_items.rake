desc 'To scrape turn14 items through api call'
task export_t14_items: :environment do
  token = Curb.t14_auth_token['access_token']
  items_url = "#{ENV['TURN14_STORE']}/v1/items?page=1"
  supplier = Supplier.find_or_create_by(supplier_id: 'turn14', name: 'Turn 14')
  loop do
    items = Curb.make_get_request(items_url, token)
    puts 'start inserting a page into db'
    if items['data'].present?
      items['data'].each do |item|
        item_hash = item['attributes']
        next if item_hash.blank?

        puts 'Turn14 Product added'
        Turn14Product.add_t14_product(
          supplier,
          item['id'],
          item_hash['product_name'],
          item_hash['part_number'],
          item_hash['mfr_part_number'],
          item_hash['brand_id']
        )
      end
    end
    exit if items['links']['next'].nil?

    items_url = ENV['TURN14_STORE'] + items['links']['next']
  rescue StandardError => e
    puts "exception #{e}"
    sleep 1
    token = Curb.t14_auth_token['access_token']
    retry
  end
end
