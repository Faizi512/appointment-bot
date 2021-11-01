desc 'To scrape usp motor sports products from uspmotorsports.com'
task scrape_uspmotorsports_products: :environment do
  store = Store.find_by(name: 'uspmotorsports')
  home_doc = Curb.get_doc(store.href)
  categories = home_doc.at('.top-categories-dropdown').css('ul').css('li')
  puts 'categories fetched'
  categories.each do |category|
    category_url = category.children[1].attributes['href'].value
    category_doc = Curb.get_doc(category_url)
    scrape_usp_pages(category_url, store) if category_doc.at('.subcategories-div .subcategories-wrap').blank?
  end
end

def scrape_usp_pages page_url, store
  page = 1
  until page.blank?
    puts "Page: #{page_url}?page=#{page}"
    page_doc = Curb.get_doc(page_url + "?page=#{page}")
    products = page_doc.xpath("//div[@class='product-item-border']")
    products.each_with_index do |product, index|
      puts "product #{index}"
      product_url = product.css('.image').children[1].attributes['href'].value
      product_doc = Curb.get_doc(product_url)      
      slug = product_url.split('/').last.split('.html').first
      data = scrap_usp_product_values(product_doc)
      add_product_to_store(store, data[:brand], data[:mpn], data[:sku], data[:inventory], slug, product_url, data[:price], data[:title])
      # puts "URL = #{product_url}"
      # puts "brand = #{data[:brand]} mpn = #{data[:mpn]} inventory = #{data[:inventory]} sku = #{data[:sku]}"
      # puts "Price #{data[:price]} Title #{data[:title]}"
    end
    next_page = begin
      page_doc.xpath('//*[@class="right-arrow"]')[0].attributes['href'].value
    rescue SignalException => e
      nil
    rescue StandardError => e
      puts e.message
      exit if e.message.eql?("undefined method `attributes' for nil:NilClass")
      UserMailer.with(user: e, script: "scrape_uspmotorsports_products").issue_in_script.deliver_now if  !e.message.eql?("undefined method `attributes' for nil:NilClass")
    end
    break if next_page.blank?
    page = next_page.split('page=')[1]
  end
end

def add_product_to_store(store, brand, mpn, sku, stock, slug, href, price, title)
  latest = store.latest_products.find_or_create_by(sku: sku)
  latest.update(brand: brand, mpn: mpn, sku: sku, inventory_quantity: stock, slug: slug, href: href, price: price, product_title: title)
  latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, sku: sku, inventory_quantity: stock, slug: slug, href: href, price: price, product_title: title)
end

def scrap_usp_product_values doc
  price_line = doc.xpath("//span[@class='currency']").children.last
  price = price_line.text if price_line.present?
  data = doc.xpath("//script[contains(text(), 'dataLayer')]").text
  {
    sku: data.split('productSKU')[1].split("': '")[1].split("'")[0],
    brand: data.split('productManufacturer')[1].split("': '")[1].split("',")[0],
    inventory: data.split('productStock')[1].split("': ")[1].split(',')[0].to_i,
    mpn: doc.at('.product-mfg-value').children.text,
    title: doc.xpath("//h1[@class='product-title']").children.text,
    price: price
  }
end
