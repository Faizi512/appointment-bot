
task :sync_supplier => :environment do
	items_response = Curl.get(ENV['SOLIDUS_STORE']) do |http|
		http.headers['Authorization'] = "Bearer #{ENV['SOLIDUS_AUTHORIZATION']}"
	end
	items = JSON.parse items_response.body_str
	turn14_ids = []

	items["products"].each do |item|
		product_name = item["name"]
		solidus_sku =  item["master"]["sku"]

		mpn_hash = item["product_properties"].select{ |property| property["property_name"] == "MPN"}.first
		mpn_id = mpn_hash["value"]

		supplier_name = "Turn14ID"
		turn14ID_hash = item["product_properties"].select{ |property| property["property_name"] == supplier_name}.first
		turn14_id = turn14ID_hash["value"]
		turn14_ids << turn14_id
		quantity = item["total_on_hand"]

		supplier ||= Supplier.find_by(supplier_id: "solidus")
		pod = supplier.products.find_or_create_by(supplier_id: supplier.id , name: product_name, solidus_sku: solidus_sku, mpn: mpn_id)
		supplier.inventories.find_or_create_by(supplier_id: supplier.id,product_id: pod.id).update(solidus_sku: solidus_sku, quantity: quantity)
	end

	#turn14 auth	
	res = Curl.post("https://api.turn14.com/v1/token", "client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")
	data = JSON.parse res.body_str

	turn14_res = Curl.get("https://api.turn14.com/v1/inventory/#{turn14_ids.join(",")}") do |http| http.headers['Authorization'] = "Bearer #{data["access_token"]}" end
	turn14_data = JSON.parse turn14_res.body_str
	supplier = Supplier.find_or_create_by(supplier_id: "turn14", name: "Turn 14")

	turn14_ids.each do |id|
	   res = Curl.get("https://api.turn14.com/v1/items/#{id}") do |http| http.headers['Authorization'] = "Bearer #{data["access_token"]}" end
	   item = JSON.parse res.body_str
	   it = turn14_data["data"].select{|it| it["id"] == id}.first
	   quantity = it["attributes"]["manufacturer"]["stock"] rescue 0
	   pod = supplier.products.find_or_create_by(supplier_id: supplier.id, name: item["data"]["attributes"]["product_name"], mpn: item["data"]["attributes"]["mfr_part_number"])
	   supplier.inventories.find_or_create_by(supplier_id: supplier.id,product_id: pod.id).update(quantity: quantity)
	end
end