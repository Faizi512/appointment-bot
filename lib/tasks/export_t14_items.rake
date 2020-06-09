
task :export_t14_items => :environment do	
	auth_data = make_post_request("#{ENV['TURN14_STORE']}/v1/token","client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")
	items_url = "#{ENV['TURN14_STORE']}/v1/items?page=1"
	supplier = Supplier.find_or_create_by(supplier_id: "turn14", name: "Turn 14")
	loop do
		begin
			items = make_get_request(items_url , auth_data["access_token"])
			break if items["links"]["next"].nil?
			items_url = ENV['TURN14_STORE'] + items["links"]["next"]
			items["data"].each do |item|
				add_t14_product(supplier,item["id"],item["attributes"]["product_name"],item["attributes"]["part_number"],item["attributes"]["mfr_part_number"],item["attributes"]["brand_id"])
			end
		puts "insert page into db"
		rescue => exception
			# byebug
			sleep 1
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

def add_t14_product(supplier,item_id,product_name,part_number,mfr_part_number,brand_id)
	supplier.turn14_products.find_or_create_by(supplier_id: supplier.id, item_id: item_id, name: product_name, part_number: part_number, mfr_part_number: mfr_part_number, brand_id: brand_id)
end