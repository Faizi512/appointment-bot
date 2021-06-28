desc 'To scrape eta of turn14 items through api call'
task t14_items_eta: :environment do
  token = Curb.t14_auth_token['access_token']
  items_url = "#{ENV['TURN14_STORE']}/v1/inventory?page=1"
  supplier = Supplier.find_or_create_by(supplier_id: 'turn14', name: 'Turn 14')
  loop do
    items = Curb.make_get_request(items_url, token)
    if items['data'].present?
      items['data'].each do |item|
        if item["attributes"]["eta"].present?
            id = item["id"]
            qty_on_order = item["attributes"]["eta"]["qty_on_order"]
            est_availability = item["attributes"]["eta"]["estimated_availability"]
        else
            next
        end
        # puts 'Turn14 Product added'
        # Turn14Product.add_t14_product(
        #   supplier,
        #   item['id'],
        #   item_hash['product_name'],
        #   item_hash['part_number'],
        #   item_hash['mfr_part_number'],
        #   item_hash['brand_id']
        # )
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
