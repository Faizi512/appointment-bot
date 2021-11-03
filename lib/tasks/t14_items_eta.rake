desc 'To scrape eta and mfr count of turn14 products through inventory paging API and catalog check'
task t14_items_eta: :environment do
  begin
    token = Curb.t14_auth_token['access_token']
    raise Exception.new "Invalid access_token" if !token.present?
  rescue Exception => e
    puts e.message
    UserMailer.with(user: e, script: "t14_items_eta").issue_in_script.deliver_no
  end
  # puts "Deleting the items from the table to clear the redundant data."
  # Turn14AvailablePromise.destroy_all
  puts "Ready to load new data"
  finalItems = []
  items_url = "#{ENV['TURN14_STORE']}/v1/inventory?page=1"
  itemsCount = 0
  loop do
    items = Curb.make_get_request items_url, token
    if items['data'].present?

      # For Catalog check
      mpn_numbers = []
      sku_numbers = {}
      get_Dopbox_Mpn_Sku(mpn_numbers, sku_numbers)
      catalog_check_against_turn14_table(mpn_numbers, sku_numbers, items["data"], finalItems)
      if finalItems.count == mpn_numbers.count || items['links']['next'].nil? 
        finalItems.each do |item|
          product = Turn14Product.find_by(item_id: item['id'])
          quantity = item['attributes']['inventory']['01'] + t14_item['attributes']['inventory']['02'] + t14_item['attributes']['inventory']['59']
          next unless t14_item
          Store.t14_itemss_insert_in_latest_and_archieve_table(product["item_id"], product['brand_id'], product['mfr_part_number'], quantity, sku_numbers[item.part_number], product['price'])
        end
      end

      # To scrape mfr count of turn14 products'
      manufacturer_and_purchase_order(items["data"])

      # To scrape eta of turn14 products'
      itemsCount += items["data"].count
      items['data'].each do |item|
        mpn = item["id"]
        if item["attributes"]["eta"].present? && item["attributes"]["eta"]["qty_on_order"].present?
          item["attributes"]["eta"]["qty_on_order"].each do |element|
            location = element[0]
            qty_on_order = element[1]
            est_availability = get_est_date(location, item)
            add_to_table(mpn, location, qty_on_order, est_availability)
          end
        else
            next
        end
      end
    end
    puts "#{itemsCount} Items processed"
    puts "Items found: #{finalItems.count}"
    exit if items['links']['next'].nil?
    items_url = ENV['TURN14_STORE'] + items['links']['next']
  rescue StandardError => e
    puts "exception #{e}"
    sleep 1
    token = Curb.t14_auth_token['access_token']
    retry
  end
end

def add_to_table mpn, location, qty, est_availability
  Turn14AvailablePromise.find_or_create_by(mpn: mpn, location: location,  quantity: qty, est_date:est_availability)
end

def get_est_date(location, item)
  est_availability = ""
  item["attributes"]["eta"]["estimated_availability"].each do |key, array|
    est_availability = item["attributes"]["eta"]["estimated_availability"][location]
  end
  est_availability
end

def manufacturer_and_purchase_order items
  items.each do |item|
    if(Turn14Product.find_by(item_id: item["id"]).present?)
      product = Turn14Product.find_by(item_id: item['id'])
      stock = item["attributes"].dig('manufacturer', 'stock')
      esd = item["attributes"].dig('manufacturer', 'esd')
      add_manufacturer(product, stock, esd) if stock.present? && esd.present?
      add_purchase_order(product, item["attributes"]["eta"]) if item["attributes"]["eta"].present?
    end
  end
end

def add_manufacturer(product, stock, esd)
  product.add_manufacturer(product, stock, esd)
end
  
def add_purchase_order(product, eta)
  product.add_latest_purchase_order(product, eta)
  product.add_archived_purchase_order(product, eta)
end

def get_Dopbox_Mpn_Sku mpn_numbers, sku_numbers
  file = Curb.open_uri(ENV['DROPBOX_URL'])
  CSV.parse(file,
            headers: true,
            header_converters: :symbol) do |row|
    mpn_numbers << row[:turn14id]
    sku_numbers[row[:turn14id].to_s] = row[:sku]
  end
end

def catalog_check_against_turn14_table(mpn_numbers, sku_numbers, items, finalItems)
  batch = []
  i = 0;
  until batch.count == mpn_numbers.count
    if(Turn14Product.where(mfr_part_number: mpn_numbers[i]).or(Turn14Product.where(part_number: mpn_numbers[i])))
      batch << sku_numbers[mpn_numbers[i]]
      i += 1
      itemIndex = find_item_for_catalog(sku_numbers[mpn_numbers[i]], items)
      if(!itemIndex.eql?(-1))
        it = items[itemIndex]
        finalItems << it
        puts it
      end
    end
    puts batch.count.to_s
  end
end

def find_item_for_catalog(id, items)
  count = 0
  items.each do |item|
    count += 1
    return count if item["id"].eql?(id)
  end
  return -1
end