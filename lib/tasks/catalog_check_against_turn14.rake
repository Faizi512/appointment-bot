desc 'To check Catalog from dropbox to turn14'
task catalog_check_against_turn14: :environment do
  file = Curb.open_uri(ENV['DROPBOX_URL'])
  mpn_numbers = []
  CSV.parse(file,
            headers: true,
            header_converters: :symbol) do |row|
    mpn_numbers << row[:turn14id]
  end
  auth_token = Curb.t14_auth_token
  until mpn_numbers.empty?
    batch = mpn_numbers.shift(250)
    items = Turn14Product.where(part_number: batch)
    items_ids = items.map(&:item_id)

    retries = 0
    begin
      retries ||= 0
      t14_items = Curb.t14_inventory_api(items_ids, auth_token['access_token'])
    rescue StandardError => e
      puts "Exception Fetching products from Turn14 #{e}"
      sleep 1
      auth_token = Curb.t14_auth_token
      retry if (retries += 1) < 3
    end

    items.each do |item|
      t14_item = t14_items['data'].select { |it| it['id'] == item['item_id'] }.first
      next unless t14_item

      quantity = t14_item['attributes']['inventory']['01'] + t14_item['attributes']['inventory']['02'] + t14_item['attributes']['inventory']['59']
      Store.t14_itemss_insert_in_latest_and_archieve_table(item['id'], item['brand_id'], item['part_number'], quantity)
    end
  end
end
