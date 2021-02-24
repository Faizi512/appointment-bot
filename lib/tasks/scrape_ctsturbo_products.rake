desc 'To scrape ctsturbo products from ctsturbo.com'
task scrape_ctsturbo_products: :environment do
  store = Store.find_by(name: 'ctsturbo')
  home_doc = Curb.get_doc(store.href)
  categories = home_doc.css('aside').css('ul').css('li').css('a')
  puts "Categories Fetched #{categories.count}"
  categories.each_with_index do |category, index|
    category_url = category.attributes['href'].value
    next if category_url.include? '#'

    category_doc = Curb.get_doc(category_url)
    next if category_doc.css('.img-wrapper').css('a').blank?

    puts "Index = #{index} URL = #{category_url}"
    products = category_doc.css('.img-wrapper').css('a')
    if category_url.include? 'product-category/other'
      scrape_other_pages(category_url, store)
    else
      scrape_cts_turbo_products(products, store)
    end
  end
end

def scrape_cts_turbo_products products, store
  products.each do |product|
    product_url = product.attributes['href'].value
    if product_url.include? 'product/'
      puts "Product URL = #{product_url}"
      product_doc = Curb.get_doc(product_url)
      data = scrap__cts_product_values(product_doc, product_url)
      puts "Price = #{data[:price]} SKU = #{data[:sku]} Title = #{data[:title]}"
      add_cts_product_to_store(store, 'CTS Turbo', data[:sku], data[:slug], data[:title], data[:price], product_url)
    else
      next
    end
  end
end

def scrape_other_pages page_url, store
  page = 1
  until page.blank?
    puts "Page: #{page_url}page/#{page}"
    page_doc = Curb.get_doc(page_url + "/page/#{page}")
    products = page_doc.css('.img-wrapper').css('a')
    products.each do |product|
      product_url = product.attributes['href'].value
      if product_url.include? 'product/'
        puts "Product URL = #{product_url}"
        product_doc = Curb.get_doc(product_url)
        data = scrap__cts_product_values(product_doc, product_url)
        puts "Price = #{data[:price]} SKU = #{data[:sku]} Title = #{data[:title]}"
        add_cts_product_to_store(store, 'CTS Turbo', data[:sku], data[:slug], data[:title], data[:price], product_url)
      else
        next
      end
    end
    next_page = begin
                  page_doc.xpath('//*[@class="next page-numbers"]')[0].attributes['href'].value
                rescue StandardError
                  nil
                end
    break if next_page.blank?

    page = next_page.split('page/')[1].split('/')[0]
  end
end

def add_cts_product_to_store(store, brand, sku, slug, title, price, href)
  latest = store.latest_products.find_or_create_by(sku: sku)
  latest.update(brand: brand, sku: sku, slug: slug, product_title: title, price: price, href: href)
  latest.archive_products.create(store_id: store.id, brand: brand, sku: sku, product_title: title, price: price, href: href)
end

def scrap__cts_product_values doc, url
  {
    price: doc.xpath("//span[@class='woocommerce-Price-amount amount']")[2].text.split('US')[1],
    title: doc.css('.product-images-wrapper').css('h1').text,
    sku: doc.xpath("//span[@class='sku_wrapper']").text.split('Code: ')[1],
    slug: url.split('product/')[1].split('/')[0]
  }
end
