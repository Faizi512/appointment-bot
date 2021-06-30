desc 'To scrape eta of turn14 items through api call'
task t14_items_eta: :environment do
  token = Curb.t14_auth_token['access_token']
  puts "Deleting the items from the table to clear the redundant data."
  Turn14AvailablePromise.destroy_all
  puts "Ready to load new data"
  items_url = "#{ENV['TURN14_STORE']}/v1/inventory?page=1"
  itemsCount = 0
  loop do
    items = Curb.make_get_request(items_url, token)
    if items['data'].present?
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