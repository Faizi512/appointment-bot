
task :sync_supplier => :environment do
	CLIENT_ID = "7240703f3c248ec80d9fd1350c69908aab972b44"
	CLIENT_SECRET = "b199db64f3c696cf6266866471930b4f574bcbc4"

	# stock_location_id = "2"
	# items_response = Curl.get("https://spagetticar.herokuapp.com/api/stock_locations/#{stock_location_id}/stock_items") do |http|
	# 	http.headers['Authorization'] = 'Bearer 3d24da66469820411b63dbef50493b13f89c07a2028de220'
	# end
	items_response = Curl.get("https://spagetticar.herokuapp.com/api/products") do |http|
		http.headers['Authorization'] = 'Bearer 3d24da66469820411b63dbef50493b13f89c07a2028de220'
	end
	items = JSON.parse items_response.body_str
	
	#turn14 auth	
	res = Curl.post("https://api.turn14.com/v1/token", "client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&grant_type=client_credentials")
	data = JSON.parse res.body_str

	items["products"].each do |item|
		product_name = item["name"]
		sku =  item["master"]["sku"]
		brand_hash = item["product_properties"].select{ |property| property["property_name"] == "Brand"}.first
		brand_name = brand_hash["value"]

		mpn_hash = item["product_properties"].select{ |property| property["property_name"] == "MPN"}.first
		mpn_id = mpn_hash["value"]

		supplier_name = "Turn14ID"
		turn14ID_hash = item["product_properties"].select{ |property| property["property_name"] == supplier_name}.first
		turn14_id = turn14ID_hash["value"]
		
		quantity = item["total_on_hand"]

		supplier = Supplier.find_or_create_by(supplier_id: turn14_id, solidus_sku: sku)
		supplier.update!(name: supplier_name)

		pod = supplier.products.find_or_create_by(supplier_id: supplier.id)
		pod.update!(name: product_name, solidus_sku: sku, mpn: mpn_id)

		supplier.inventories.find_or_create_by(supplier_id: supplier.id,product_id: pod.id).update(solidus_sku: sku, quantity: quantity)
		# sleep 0.2
		# turn14_res = Curl.get("https://api.turn14.com/v1/items/#{mpn_id}") do |http| http.headers['Authorization'] = "Bearer #{data["access_token"]}" end		
		# turn14_res = Curl.get("https://api.turn14.com/v1/items/#{turn14_id}") do |http|
		# 	http.headers['Authorization'] = "Bearer #{data["access_token"]}"
		# end
		# turn14_item = JSON.parse turn14_res.body_str
		# Supplier.find_or_create(supplier_id: id = item["id"]).update(name: name,solidus_sku: sku)
		# byebug
	end
end