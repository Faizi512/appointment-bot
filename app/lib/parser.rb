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
    when 'mmrperformance'
      mmrperformance_data_points(doc)
    end
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

  def maxtondesignusa_data_points doc
    regex = "[0-9]"
    title = doc.xpath("//a/div[2]/div")[0].text
    @title = "#{title} #{@variant["title"]}"
    price = doc.xpath("//span[@class='product__price']").text.strip
    @price = price if price.present?
    if(doc.xpath("/html/body/div[1]/div/main/div[1]/div/div/div/div[1]/div[1]/div/form/div[2]").text.strip.match(regex)[0] != nil)
      @stock = doc.xpath("/html/body/div[1]/div/main/div[1]/div/div/div/div[1]/div[1]/div/form/div[2]").text.strip.match(regex)[0].to_i
    else
      regex << "+#{regex}"
      @stock = doc.xpath("/html/body/div[1]/div/main/div[1]/div/div/div/div[1]/div[1]/div/form/div[2]").text.strip.match("regex")[0].to_i
    end
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

  def data_points_hash
    {
      stock: @stock, mpn: @mpn, brand: @brand,
      sku: @sku, price: @price, title: @title
    }
  end
end
