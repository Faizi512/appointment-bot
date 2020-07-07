class Parser

	require 'nokogiri'
	attr_reader :file
	attr_reader :store_id

	def initialize(file, store_id)
		@file = file		
		@store_id = store_id
	end

	def parse
		doc = Nokogiri::HTML(file)
		
		if store_id == "urotuning"
			@brand = doc.xpath('.//meta[@itemprop=$value]', nil, {:value => 'brand'}).first.attributes["content"].value rescue nil
			@mpn = doc.xpath('.//meta[@itemprop=$value]', nil, {:value => 'mpn'}).first.attributes["content"].value rescue nil
			@inventory_quantity =JSON.parse(doc.xpath('.//script[@data-app=$value]', nil, {:value => 'esc-out-of-stock'}).first.children.first).first["inventory_quantity"] rescue nil

		elsif store_id == "performancebyie"
			txt = doc.xpath('//script')[27].children.text
			@inventory_quantity = txt.split('inventory_quantity: ', 2).last.split('product_id:')[0].split(',')[0] rescue nil
			@mpn = @mpn = doc.xpath("//*[contains(concat(' ', normalize-space(@class), ' '), 'product-single__sku')]").text.strip
		end
		to_json
	end

	def to_json
		{
			inventory_quantity: @inventory_quantity, 
			mpn: @mpn,
			brand: @brand
		}

	end
end