require 'nokogiri'
class Parser
  attr_reader :file, :store

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
    @stock = txt.split("\"id\":#{@variant['id']}", 2).last.split('inventory_quantity', 2).last.split(',')[0].split(':')[1] rescue nil
    @mpn = @variant['product_id']
    data_points_hash
  end

  def data_points_hash
    {
      inventory_quantity: @stock, mpn: @mpn, brand: @brand,
      sku: @sku, price: @price, title: @title
    }
  end
end
