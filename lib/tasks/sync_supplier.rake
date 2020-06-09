
task :sync_supplier => :environment do
	solidus_products = make_get_request("#{ENV['SOLIDUS_STORE']}/products",ENV['SOLIDUS_AUTHORIZATION'])
	turn14_ids = []

	solidus_products["products"].each do |item|
		mpn_hash = item["product_properties"].select{ |property| property["property_name"] == "MPN"}.first
		turn14ID_hash = item["product_properties"].select{ |property| property["property_name"] == "Turn14ID"}.first
		turn14_ids << turn14ID_hash["value"]

		supplier ||= Supplier.find_by(supplier_id: "solidus")
		add_product_in_inventory(supplier,item["name"],mpn_hash["value"],item["total_on_hand"],item["master"]["sku"])
	end

	#turn14 auth
	auth_data = make_post_request("#{ENV['TURN14_STORE']}/v1/token","client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")
	inventory_data = make_get_request("#{ENV['TURN14_STORE']}/v1/inventory/#{turn14_ids.join(",")}",auth_data["access_token"])

	turn14_ids.each do |id|
	   item = make_get_request("#{ENV['TURN14_STORE']}/v1/items/#{id}", auth_data["access_token"])
	   inventory_item = inventory_data["data"].select{|it| it["id"] == id}.first
	   quantity = inventory_item["attributes"]["inventory"]["01"] + inventory_item["attributes"]["inventory"]["02"] +inventory_item["attributes"]["inventory"]["59"]

	   supplier ||= Supplier.find_or_create_by(supplier_id: "turn14", name: "Turn 14")
	   add_product_in_inventory(supplier,item["data"]["attributes"]["product_name"],item["data"]["attributes"]["mfr_part_number"],quantity)
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

def add_product_in_inventory(supplier,product_name,part_number,quantity,solidus_sku = nil)
	product = supplier.products.find_or_create_by(supplier_id: supplier.id, name: product_name, mpn: part_number, solidus_sku: solidus_sku)
	supplier.inventories.find_or_create_by(supplier_id: supplier.id,product_id: product.id).update(quantity: quantity, solidus_sku: solidus_sku)
end