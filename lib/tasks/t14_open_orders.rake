desc 'To check turn14 open orders through api'
task :t14_open_orders => :environment do
	begin
		t14_token = make_post_request("#{ENV['TURN14_STORE']}/v1/token","client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")
		raise Exception.new "Invalid token" if !t14_token.present?
		order_url = "#{ENV['TURN14_STORE']}/v1/orders"
		supplier = Supplier.find_or_create_by(supplier_id: "turn14", name: "Turn 14")
		t14_order_numbers = []
		loop do
			begin
				orders = make_get_request(order_url , t14_token["access_token"])
				puts "start inserting a orders into db"
				orders["data"].each do |order|
					t14_order_numbers << sales_order = order["attributes"]["order_number"]
					purchase_order = order["attributes"]["purchase_order_number"]
					date = order["attributes"]["date"]
					order["attributes"]["lines"].each do |line|
						if line["esd"].first["quantity"] != 0
							eta_info = "#{line["esd"].first["quantity"]} expected on #{line["esd"].first["date"]} per MFR update on #{line["esd"].first["last_updated"]}" rescue "Awating Update"
						else
							eta_info = "Awating Update"
						end
						add_t14_order(supplier,date,purchase_order,sales_order,line["part_number"],line["quantity"],line["open_quantity"],eta_info)
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
		Turn14OpenOrder.where.not(sales_order: t14_order_numbers).delete_all
	rescue SignalException => e
		nil
	rescue Exception => e
		puts e.message
        UserMailer.with(user: e, script: "t14_open_orders").issue_in_script.deliver_now
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

def add_t14_order(supplier,date,purchase_order,sales_order,part_number,quantity,open_quantity,eta_info,warehouse=nil)
	supplier.turn14_open_orders.find_or_create_by(supplier_id: supplier.id,sales_order:sales_order).update(date: date,purchase_order:purchase_order,part_number: part_number, quantity: quantity, open_qty: open_quantity, eta_information: eta_info,warehouse:warehouse)
end