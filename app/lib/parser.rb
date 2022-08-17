require 'nokogiri'
class Parser
  attr_reader :file, :store
  @index = 1
  def initialize(file, store, variant, brand)
    @file = file
    @store = store
    @variant = variant
    @brand = brand
    @sku = variant['sku']
    @price = ''
    @title = ''
  end

  def parse
    doc = Nokogiri::HTML(file)
    case store
    when 'urotuning'
      urotuning_data_points(doc)
    when 'performancebyie'
      performancebyie_data_points(doc)
    when 'bmptuning'
      bmptuning_data_points(doc)
    when 'maxtondesignusa'
      maxtondesignusa_data_points(doc)
    when 'NeuspeedRSWheels'
      neuspeedRSWheels_data_points(doc)
    when 'MMRPerformance'
      mmrperformance_data_points(doc)
    when 'throtl'
      throtl_data_points(doc)
    when 'maperformance'
      maperformance_data_points(doc)
    when 'spaturbousa'
      spa_turbo_usa(doc)
    when 'fastmods'
      fastmods_data_points(doc)
    end
  end

  def fastmods_data_points doc
    @title = doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/h1").children[2].text.strip rescue nil
    salePrice = doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/div[2]/span[2]").children.text.strip() rescue  nil
    regularPrice=doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/div[2]/span[1]").children.text.strip() rescue  nil
    @price=salePrice.present? ? salePrice : regularPrice
    @brand=doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/div[3]/div[1]/div[1]/span/a").children.last.text rescue nil
    stock=doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/div[3]/div[1]/div[6]/span/span[2]").text rescue nil
    @stock=stock.eql?("Many in stock") ? 1 : 0
    data_points_hash
  end
  def throtl_data_points doc
    @title = doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[1]/h1").text.strip rescue nil 
    price=doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[3]/div/dl/div[1]/dd/span").children.text.strip() rescue nil
    if price.present?  
    @price= price.split(' ').count >1 ? price.split(' ')[0] : price
    else
    @price=price
    end 
    stock=doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[2]/div[2]/div/div").children[1].children.text rescue nil
    @stock=stock.present? ?  stock.gsub(/[^0-9]/, '').to_i : 0
    mpn=doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[2]/div[1]/p") rescue nil
    @mpn=mpn.children.present? ? mpn.children.last.text : nil
    brand=doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[1]/div[1]/a") rescue nil
    @brand=brand.children.present? ? brand.last.text : nil
    data_points_hash
  end
   
  def spa_turbo_usa(doc)
    title=doc.xpath("/html/head/meta[7]") rescue nil
    @title=title[0].present? ? title[0].attributes["content"].value : nil
    @price=doc.xpath("/html/body/div[4]/div[2]/div[2]/div/div/div/div[2]/div/div[1]/div/div/div/div[2]/div/div/div/div[1]/div[1]/form/div[2]/div[1]/div/span").children.text rescue nil
    mpn=doc.xpath("/html/body/div[4]/div[2]/div[2]/div/div/div/div[2]/meta[3]") rescue nil
    @mpn=mpn[0].present? ? mpn[0].attributes["content"].value : nil
    stock=doc.xpath("/html/body/div[4]/div[2]/div[2]/div/div/div/div[2]/div/div[1]/div/div/div/div[2]/div/div/div/div[1]/div[1]/form/div[2]/div[2]/span").text rescue nil
    @stock= stock.present? ? 1 : 0
    @brand = doc.xpath("/html/body/div[4]/div[2]/div[2]/div/div/div/div[2]/span[3]").children.text rescue ni
    data_points_hash
  end

  def urotuning_data_points doc
    @title = doc.xpath("//h2[@itemprop='name']").children.text
    price = doc.xpath("//span[@class='bold_option_price_display price']").children.last
    @price = price.text.strip if price.present?
    @brand = doc.xpath('.//meta[@itemprop=$value]', nil, { value: 'brand' }).first.attributes['content'].value rescue nil
    @mpn = doc.xpath('.//meta[@itemprop=$value]', nil, { value: 'mpn' }).first.attributes['content'].value rescue nil
    @stock = JSON.parse(doc.xpath('.//script[@data-app=$value]', nil, { value: 'esc-out-of-stock' }).first.children.first).first['inventory_quantity'] rescue nil
    data_points_hash
  end 
  def performancebyie_data_points doc
    @title = doc.xpath("//h1[@itemprop='name']").children.text
    price = doc.xpath("//span[@class='product__price']").children.last
    @price = price.text.strip if price.present?
    txt = doc.xpath("//script[contains(text(), 'inventory_quantity')]").text
    @stock = txt.split("\"id\":#{@variant['id']}")[2].split('inventory_quantity: ', 2).last.split('product_id:')[0].split(',')[0] rescue nil
    @mpn = doc.xpath("//*[contains(concat(' ', normalize-space(@class), ' '), 'product-single__sku')]").text.strip
    data_points_hash
  end

  def bmptuning_data_points doc
    @title = doc.xpath("//h1[@class='product-meta__title heading h1']").children.text
    price = doc.xpath("//span[@class='price']").children.last
    @price = price.text if price.present?
    txt = doc.xpath("//script[contains(text(), 'inventory_quantity')]").text
    @stock = txt.split("\"id\":#{@variant['id']}", 2).last.split('inventory_quantity', 2).last.split(',')[0].split(':')[1].to_i rescue nil
    @mpn = @variant['product_id']
    data_points_hash
  end

  def neuspeedRSWheels_data_points(doc)
    hash_data=[]
    @title=doc.xpath("//h1[@class='product-title']").children.text.strip
    data=doc.xpath("//select/option[@data-variant-id]")
      data.each do |products|
        stock_data = products.attributes["data-variant-quantity"].value.to_i
        @stock = stock_data > 0 ? stock_data : 0
        @price = products.children[0].text.strip.split.last.to_f
        @mpn=products.attributes["data-sku"].value
        hash_data.push(data_points_hash)
      end
    hash_data
  end

  def mmrPerformance_data_points(doc)
    @title=doc.xpath('/html/body/main/div[2]/div/div/div/div/div/div/div/div[2]/div[1]/div[2]/h1').children.text.strip
    @price=doc.xpath('/html/body/main/div[2]/div/div/div/div/div/div/div/div[2]/div[1]/div[5]/div/span/span').children.text.split("£")[1].to_f
    @mpn=doc.xpath('/html/body/main/div[2]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[1]/p/span').children.text
    @stock=doc.xpath('/html/body/main/div[2]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[2]/p/span').children.text.scan(/\d+/).first.to_i
    data_points_hash
  end

  def maxtondesignusa_data_points doc
    title = doc.xpath("/html/body/div[1]/div/main/div[1]/div/div/div/div[1]/div[1]/div/h1").text.strip() rescue nil 
    variant_title= @variant["title"].present? ? @variant["title"] : nil 
    @title = "#{title} #{variant_title}" rescue nil
    price = doc.xpath("/html/body/div[1]/div/main/div[1]/div/div/div/div[1]/div[1]/div/span[2]").price.strip() rescue nil
    @price = price if price.present?
    stock=doc.xpath("//div[@class='product__inventory hide']").text.strip.split(' ')[1].to_i rescue nil
    @stock = stock < 0 ? 0 : stock
    @mpn = @variant['product_id']
    data_points_hash
  end

  def mmrperformance_data_points(doc)
    @title = doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[2]/h1').text
    @price = doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[5]/div/span').text.present? ? doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[5]/div/span').text.split("£")[1]: ""
    txt = doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[2]/p').text
    @stock = !txt.scan(/\d/).empty? ? doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[2]/p').text.split("(")[1].split(" ")[0] : "0"
    @mpn = doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[1]/p').text.present? ? doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[1]/p').text.split(":")[1] : ""
    data_points_hash
  end

  def maperformance_data_points(doc)
    @brand=doc.xpath('/html/body/main/div/div[3]/div[1]/div/div/div/div[1]/div[2]/div/a').text
    @title=doc.xpath('/html/body/main/div/div[3]/div[1]/div/div/div/div[1]/div[2]/div/h1').text
    @mpn=doc.xpath('/html/body/main/div/div[3]/div[1]/div/div/div/div[1]/div[2]/div/span[1]/strong').text.split('#').last
    @price=doc.xpath('/html/body/main/div/div[3]/div[1]/div/div/div/div[1]/div[2]/div/span[5]/p/span[1]').text
    raw_data=doc.xpath("//script[@class='product-json']").text
    if !raw_data.blank?
      data=JSON[raw_data]
      @stock=data['variants'].present? ? data['variants'][0]["inventory_quantity"] : 0
    else
      @stock=0
    end
    data_points_hash
  end

  def data_points_hash
    {
      stock: @stock, mpn: @mpn, brand: @brand,
      sku: @sku, price: @price, title: @title
    }
  end
end
