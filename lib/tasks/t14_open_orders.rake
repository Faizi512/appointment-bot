
task :t14_open_orders => :environment do	
	t14_token = make_post_request("#{ENV['TURN14_STORE']}/v1/token","client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")
	order_url = "#{ENV['TURN14_STORE']}/v1/orders"
	supplier = Supplier.find_or_create_by(supplier_id: "turn14", name: "Turn 14")
	Turn14OpenOrder.delete_all

	loop do
		begin
			orders = make_get_request(order_url , t14_token["access_token"])
			puts "start inserting a orders into db"
			orders["data"].each do |order|
				sales_order = order["attributes"]["order_number"]
				purchase_order = order["attributes"]["purchase_order_number"]
				date = order["attributes"]["date"]
				order["attributes"]["lines"].each do |line|
					add_t14_order(supplier,date,purchase_order,sales_order,line["part_number"],line["quantity"],line["open_quantity"])
				end
			end
			break if orders["links"]["next"].nil?
			order_url = ENV['TURN14_STORE'] + orders["links"]["next"]
		rescue => exception
			puts"exception #{exception}"
			sleep 1
			t14_token = make_post_request("#{ENV['TURN14_STORE']}/v1/token","client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")
			retry
		end
	end
end


def make_get_request(url,token)
	response = Curl.get(url) do |http|
		http.headers['Authorization'] = "Bearer #{token}"
	end
	JSON.parse response.body_str
end

def make_post_request(url,parameters)
	response = Curl.post(url, parameters)
	JSON.parse response.body_str
end

def add_t14_order(supplier,date,purchase_order,sales_order,part_number,quantity,open_quantity,eta_info=nil,warehouse=nil)
	supplier.turn14_open_orders.create(supplier_id: supplier.id, date: date,purchase_order:purchase_order,sales_order:sales_order,part_number: part_number, quantity: quantity, open_qty: open_quantity, eta_information: eta_info,warehouse:warehouse)
end