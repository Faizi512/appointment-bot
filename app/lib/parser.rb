require 'nokogiri'
class Parser
	attr_reader :file
	attr_reader :store_id

	def initialize(file, store_id,variant,brand)
		@file = file		
		@store_id = store_id
		@variant = variant
		@brand = brand
		@sku = variant["sku"]
	end

	def parse
		doc = Nokogiri::HTML(file)
		
		if store_id == "urotuning"
			@brand = doc.xpath('.//meta[@itemprop=$value]', nil, {:value => 'brand'}).first.attributes["content"].value rescue nil
			@mpn = doc.xpath('.//meta[@itemprop=$value]', nil, {:value => 'mpn'}).first.attributes["content"].value rescue nil
			@inventory_quantity =JSON.parse(doc.xpath('.//script[@data-app=$value]', nil, {:value => 'esc-out-of-stock'}).first.children.first).first["inventory_quantity"] rescue nil

		elsif store_id == "performancebyie"
			txt = doc.xpath("//script[contains(text(), 'inventory_quantity')]").text
			@inventory_quantity =  txt.split("\"id\":#{@variant["id"]}")[2].split('inventory_quantity: ', 2).last.split('product_id:')[0].split(',')[0] rescue nil
			@mpn = doc.xpath("//*[contains(concat(' ', normalize-space(@class), ' '), 'product-single__sku')]").text.strip
		elsif store_id == "bmptuning"
			txt = doc.xpath("//script[contains(text(), 'inventory_quantity')]").text
			@inventory_quantity = txt.split("\"id\":#{@variant["id"]}",2).last.split('inventory_quantity',2).last.split(',')[0].split(':')[1] rescue nil
			@mpn = @variant["product_id"]
		end
		{
			inventory_quantity: @inventory_quantity, 
			mpn: @mpn,
			brand: @brand,
			sku: @sku
		}
	end
end