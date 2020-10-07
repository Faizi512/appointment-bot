task export_t14_items: :environment do
  auth_token = Curb.t14_auth_token
  token = auth_token['access_token']
  items_url = "#{ENV['TURN14_STORE']}/v1/items?page=1"
  supplier = Supplier.find_or_create_by(supplier_id: 'turn14', name: 'Turn 14')
  loop do
    items = Curb.make_get_request(items_url, token)
    puts 'start inserting a page into db'
    items['data'].each_with_index do |item, index|
      item_hash = item['attributes']
      product = Turn14Product.add_t14_product(supplier, item['id'], item_hash['product_name'], item_hash['part_number'], item_hash['mfr_part_number'], item_hash['brand_id'])
      item_data = Curb.t14_inventory_api_sigle_item(item['id'], token)
      stock = begin
           item_data['data'][0]['attributes']['manufacturer']['stock']
              rescue StandardError
                nil
         end
      esd = begin
         item_data['data'][0]['attributes']['manufacturer']['esd']
            rescue StandardError
              nil
       end
      if stock.present? && esd.present?
        puts "manufacturer present #{index}"
        Manufacturer.add_manufacturer(product, stock, esd)
      else
        puts (item['id']).to_s
      end
    end
    break if items['links']['next'].nil?

    items_url = ENV['TURN14_STORE'] + items['links']['next']
  rescue StandardError => e
    puts "exception #{e}"
    sleep 1
    auth_token = Curb.t14_auth_token
    retry
  end
end
