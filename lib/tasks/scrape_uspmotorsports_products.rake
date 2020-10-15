task scrape_uspmotorsports_products: :environment do
  store = Store.find_by(name: 'uspmotorsports')
  home_doc = Curb.get_doc((ENV['USP_STORE']).to_s)
  categories = home_doc.at('.top-categories-dropdown').css('ul').css('li')
  puts 'categories fetched'
  categories.each do |category|
    category_url = category.children[1].attributes['href'].value
    category_doc = Curb.get_doc(category_url)
    scrape_pages(category_url, store) if category_doc.at('.subcategories-div .subcategories-wrap').blank?
  end
end

def scrape_pages page_url, store
  page = 1
  until page.blank?
    puts "Page: #{page_url}?page=#{page}"
    page_doc = Curb.get_doc(page_url + "?page=#{page}")
    products = page_doc.xpath("//div[@class='product-item-border']")
    products.each_with_index do |product, index|
      puts "product #{index}"
      product_url = product.css('.image').children[1].attributes['href'].value
      product_doc = Curb.get_doc(product_url)
      data = scrap_product_values(product_doc)
      add_product_to_store(store, data[:brand], data[:mpn], data[:sku], data[:inventory], data[:slug], product_url)
      # puts "brand = #{data[:brand]} mpn = #{data[:mpn]} inventory = #{data[:inventory]} sku = #{data[:sku]}"
      # puts "URL = #{product_url}"
      # byebug
    end
    next_page = begin
                  page_doc.xpath('//*[@class="right-arrow"]')[0].attributes['href'].value
                rescue StandardError
                  nil
                end
    break if next_page.blank?

    page = next_page.split('page=')[1]
  end
end

def add_product_to_store(store, brand, mpn, sku, stock, slug, href)
  latest = store.latest_products.find_or_create_by(sku: sku)
  latest.update(brand: brand, mpn: mpn, sku: sku, inventory_quantity: stock, slug: slug, href: href)
  latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, sku: sku, inventory_quantity: stock, slug: slug, href: href)
end

def scrap_product_values doc
  data = doc.xpath("//script[contains(text(), 'dataLayer')]").text
  {
    sku: data.split('productSKU')[1].split("': '")[1].split("'")[0],
    slug: data.split('productName')[1].split("': '")[1].split("',")[0],
    brand: data.split('productManufacturer')[1].split("': '")[1].split("',")[0],
    inventory: data.split('productStock')[1].split("': ")[1].split(',')[0].to_i,
    mpn: doc.at('.product-mfg-value').children.text
  }
end
