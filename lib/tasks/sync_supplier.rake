
task :sync_supplier => :environment do
	solidus_products = make_get_request("#{ENV['SOLIDUS_STORE']}/products",ENV['SOLIDUS_AUTHORIZATION'])
	part_number_array = []
	solidus_supplier = Supplier.find_by(supplier_id: "solidus")
	t14_supplier = Supplier.find_or_create_by(supplier_id: "turn14", name: "Turn 14")

	solidus_products["products"].each do |item|
		part_number = item["product_properties"].select{ |property| property["property_name"] == "Turn14ID"}.first
		part_number_array << part_number["value"]
		add_product_in_inventory(solidus_supplier,item["name"],part_number["value"],item["total_on_hand"],item["master"]["sku"])
	end
	t14_auth_data = make_post_request("#{ENV['TURN14_STORE']}/v1/token","client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")

	until part_number_array.empty?
		batch = part_number_array.shift(250)
		t14_products = Turn14Product.where(part_number: batch)
		item_ids = t14_products.map(&:item_id)
		retries = 0
		begin
			retries ||= 0
			inventory_items = make_get_request("#{ENV['TURN14_STORE']}/v1/inventory/#{item_ids.join(",")}",t14_auth_data["access_token"])
		rescue => exception
			puts "Exception #{exception}"
			sleep 1
			t14_auth_data = make_post_request("#{ENV['TURN14_STORE']}/v1/token","client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")
			retry if (retries += 1) < 3
		end
		t14_products.each do |item|
			inventory_item = inventory_items["data"].select { |inventory_item| inventory_item["id"] == item["item_id"]}.first
			quantity = inventory_item["attributes"]["inventory"]["01"] + inventory_item["attributes"]["inventory"]["02"] + inventory_item["attributes"]["inventory"]["59"]
			solidus_product = solidus_products["products"].select {|product| product["product_properties"].find{ |property| property["value"] == item["part_number"]}}.first
			add_product_in_inventory(t14_supplier,solidus_product["name"],item["part_number"],quantity,solidus_product["master"]["sku"])
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

def add_product_in_inventory(supplier,product_name,part_number,quantity,solidus_sku)
	product = supplier.products.find_or_create_by(supplier_id: supplier.id,mpn: part_number)
	product.update(name: product_name, solidus_sku: solidus_sku)
	supplier.inventories.find_or_create_by(supplier_id: supplier.id,product_id: product.id).update(quantity: quantity, solidus_sku: solidus_sku)
end