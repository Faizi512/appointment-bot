require "uri"
require "net/http"
require 'nokogiri'
require 'open-uri'

task :sync_with_store => :environment do
	store = Store.find_by_store_id("urotuning")
	products = begin
		get_request("#{store.href}.json")
	rescue => e
		puts "Exception throws getting products"
		sleep 60
		retry
	end		
	products["products"].each do |product|
		begin
			product_slug = product["handle"]
			product["variants"].each do |variant|
				variant_href = "#{store.href}/#{product_slug}?variant=#{variant["id"]}"
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
					add_product_in_store(store,brand,mpn,variant["sku"],inventory_quantity,product_slug,variant["id"],variant["product_id"],variant_href)
					puts "brand #{brand} mpn #{mpn} inventory_quantity #{inventory_quantity} sku #{variant["sku"]}}"
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

def add_product_in_store(store,brand,mpn,sku,inventory_quantity,slug,variant_id,product_id,href)
	latest = store.latest_products.find_or_create_by(variant_id: variant_id, product_id: product_id)
	latest.update(brand: brand,mpn: mpn,sku: sku,inventory_quantity: inventory_quantity,slug: slug,href: href)
	latest.archive_products.create(store_id:store.id,brand: brand,mpn: mpn,sku: sku,inventory_quantity: inventory_quantity,slug: slug,variant_id: variant_id,product_id: product_id,href: href)
end