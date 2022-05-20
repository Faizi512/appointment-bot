desc 'To scrape turn14 items through api call'
task export_t14_items: :environment do
  begin
    token = Curb.t14_auth_token['access_token']
    raise Exception.new "Invalid token" if !token.present?
    items_url = "#{ENV['TURN14_STORE']}/v1/items?page=447"
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
            item_hash['brand_id'],
            item_hash['brand'],
            item_hash['active'],
            item_hash['regular_stock'],
            item_hash['not_carb_approved'],
            item_hash['alternate_part_number'],
            item_hash['barcode'],
            item_hash['prop_65'],
            item_hash['epa']
          )
        end
      end
      if items['links']['next'].nil?
        raise Exception.new "Exiting the script"
        exit 
      end

      items_url = ENV['TURN14_STORE'] + items['links']['next']
    rescue StandardError => e
      puts "exception #{e}"
      sleep 1
      token = Curb.t14_auth_token['access_token']
      retry
    end
  rescue Exception => e
    if !e.message.eql?("Exiting the script")
      puts e.message
      UserMailer.with(user: e, script: "export_t14_items").issue_in_script.deliver_now
    end
  end
end
