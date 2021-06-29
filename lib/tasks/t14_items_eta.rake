desc 'To scrape eta of turn14 items through api call'
task t14_items_eta: :environment do
  token = Curb.t14_auth_token['access_token']
  Turn14AvailablePromise.destroy_all
  items_url = "#{ENV['TURN14_STORE']}/v1/inventory?page=1"
  supplier = Supplier.find_or_create_by(supplier_id: 'turn14', name: 'Turn 14')

  loop do
    items = Curb.make_get_request(items_url, token)
    # byebug
    puts "#{1000 * items['links']['self'][19..-1].to_i} Items processed"
    if items['data'].present?
    
      items['data'].each do |item|
        mpn = item["id"]
        if item["attributes"]["eta"].present?
          item["attributes"]["eta"]["qty_on_order"].each do |element|
            location = element[0]
            qty_on_order = element[1]
            est_availability = get_est_date(location, item)
            set_location_est_date(mpn, location, qty_on_order, est_availability)
          end
        else
            next
        end
      end
    end
    exit if items['links']['next'].nil?
    items_url = ENV['TURN14_STORE'] + items['links']['next']
  rescue StandardError => e
    puts "exception #{e}"
    sleep 1
    token = Curb.t14_auth_token['access_token']
    
    items_url = ENV['TURN14_STORE'] + items['links']['next']
    retry
  end
end

def set_location_est_date mpn, location, qty, est_availability
  # puts "{mpn: #{mpn}, location: #{location}, qty: #{qty}, est_availability_date: #{est_availability}}"
  Turn14AvailablePromise.find_or_create_by(mpn: mpn, location: location,  quantity: qty, est_date:est_availability)
end

def get_est_date(location, item)
  est_availability = ""
  item["attributes"]["eta"]["estimated_availability"].each do |key, array|
    est_availability = item["attributes"]["eta"]["estimated_availability"][location]
  end
  est_availability
end