desc 'To scrape eta of turn14 items through api call'
task t14_items_eta: :environment do
token = Curb.t14_auth_token['access_token']
Turn14AvailablePromise.destroy_all
items_url = "#{ENV['TURN14_STORE']}/v1/inventory?page=1"
loop do
items = Curb.make_get_request(items_url, token)
if items['data'].present?
items['data'].each do |item|
mpn = item["id"]
if item["attributes"]["eta"].present?
item["attributes"]["eta"]["qty_on_order"].each do |element|
location = element[0]
qty_on_order = element[1]
est_availability = set_est_date(location, qty_on_order, item)
# set_location_est_date(mpn, location, qty_on_order, est_availability)
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
retry
end
end


def set_location_est_date mpn, location, qty, est_availability
puts "{#{mpn}, #{location}, #{qty}, #{est_availability}}"
# t14_promise_table = Turn14AvailablePromise.find_or_create_by(mpn: mpn, location: location)
# t14_promise_table.update(qty, est_availability)
end

def set_est_date(location, qty, item)
byebug
puts location
puts qty
puts item

end

# def add_t14_eta(supplier,date,purchase_order,sales_order,part_number,quantity,open_quantity,eta_info,warehouse=nil)
# supplier.turn14_open_orders.find_or_create_by(supplier_id: supplier.id,sales_order:sales_order).update(date: date,purchase_order:purchase_order,part_number: part_number, quantity: quantity, open_qty: open_quantity, eta_information: eta_info,warehouse:warehouse)
# end
