require "uri"
require "net/http"
require 'nokogiri'
require 'open-uri'

task :sync_with_store => :environment do
	products = begin 
		get_request("#{ENV['UROTURN']}.json")
	rescue => e
		puts "Exception throws getting products"
		sleep 60
		retry
	end		
	products["products"].each do |product|
		begin
			product_slug = product["handle"]
			product["variants"].each do |variant|
				variant_id = variant["id"]
				product_id = variant["product_id"]
				variant_sku = variant["sku"]
				variant_href = "#{ENV['UROTURN']}/#{product_slug}?variant=#{variant_id}"
				file = begin
					URI.open(variant_href)
				rescue OpenURI::HTTPError => e
					puts "EXception in OpenURI #{e}"
					sleep 60 * 5
					retry
				end
				retries = 0
				begin
					retries ||= 0
					doc = Nokogiri::HTML(file)
					brand = doc.xpath('.//meta[@itemprop=$value]', nil, {:value => 'brand'}).first.attributes["content"].value rescue nil
					mpn = doc.xpath('.//meta[@itemprop=$value]', nil, {:value => 'mpn'}).first.attributes["content"].value rescue nil
					inventory_quantity =JSON.parse(doc.xpath('.//script[@data-app=$value]', nil, {:value => 'esc-out-of-stock'}).first.children.first).first["inventory_quantity"] rescue nil
					puts "brand #{brand} mpn #{mpn} inventory_quantity #{inventory_quantity} sku #{variant_sku}}"
				rescue => e
					puts "EXception in Parsing Nokogiri::HTML #{e}"
					sleep 1
					retry if (retries += 1) < 3
				end
		rescue => e
			puts "EXception in finding product variant #{e}"
			next			
		end
		end
	end
end

def get_request(urll)
	url = URI(urll)
	https = Net::HTTP.new(url.host, url.port);
	https.use_ssl = true

	request = Net::HTTP::Get.new(url)
	response = https.request(request)
	JSON.parse response.read_body
end

def add_product_in_inventory(supplier,product_name,part_number,quantity,solidus_sku)
	product = supplier.products.find_or_create_by(supplier_id: supplier.id,mpn: part_number)
	product.update(name: product_name, solidus_sku: solidus_sku)
	supplier.inventories.find_or_create_by(supplier_id: supplier.id,product_id: product.id).update(quantity: quantity, solidus_sku: solidus_sku)
end