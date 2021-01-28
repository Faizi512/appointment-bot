require 'watir'
require 'webdrivers/chromedriver'
task tuner_price_products: :environment do
  store = Store.find_by(name: 'tunerprice')
  sections = %w[/index.php/audi.html /index.php/vw.html]
  browser = Watir::Browser.new
  
  # Navigate to Page
  browser.goto store.href

  # Authenticate and Navigate to the store
  browser.text_field(xpath: '//*[@id="email"]').set ENV['TUNER_PRICE_USERNAME']
  browser.text_field(xpath: '//*[@id="pass"]').set ENV['TUNER_PRICE_PASSWORD']
  browser.button(xpath: '//*[@id="send2"]').click

  sections.each do |sec|
    page = 1
    until page.blank?
      url = "#{store.href}#{sec}?p=#{page}"
      browser.goto url
      puts "\n *********************************************************************************"
      catagories = []
      browser.element(xpath: '//div[@class="category-products"]').elements(css: 'ul li a').select{|a| catagories<<a.href}
      catagories.each_with_index do |prod_url, index|
        next if index.even?
        next if prod_url.include? 'catalog'
        puts "Index=#{index} URL=#{prod_url}"
        browser.goto prod_url
        title = browser.div(class: 'product-name').text
        availability = browser.p(class: 'availability').text.split(': ').last
        sku = browser.div(class: 'product-shop').text.split('Sku: ')[1].split("\n").first
        qty = 0 if availability == 'Out of stock'
        qty = 12 if availability == 'In stock'
        qty = browser.p(class: 'availability-only').text.split(' ')[1].to_i if browser.p(class: 'availability-only').present?
        puts "Title=#{title} SKU=#{sku} Avail=#{availability} Qty=#{qty}"
        puts "#########################################################"
        new_product = EmotionProduct.find_or_create_by(sku: sku)
        new_product.update(title: title, brand: 'Emotion', qty: qty, href: prod_url)   
      end
      browser.goto url
      next_page = begin
                    browser.a(class: 'i-next').href
                  rescue StandardError
                    nil
                  end
      break if next_page.blank?

      page = next_page.split('p=').last.to_i
    end
    
  end
  browser.close
end