require 'watir'
require 'webdrivers/chromedriver'

desc 'To scrap inventory data from Vargas Turbo using watir'
task :vargas_turbo => :environment do
    store = Store.find_by(name: 'vargas_turbo')
    

    Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH']
    Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']

    # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
    # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    
    browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222]

    file = Curb.open_uri(store.href)
    doc = Nokogiri::HTML(file).at('body')

    pageNumber = doc.xpath('//*[@id="post-1037"]/div/div/div/div[2]/div/div[4]/div/nav/span[1]').text().to_i
    totalProducts = doc.xpath('//*[@id="post-1037"]/div/div/div/div[2]/div/div[4]/div/p').text().split(" ")[3].to_i
    productCount = 1
    totalGrabedCount = 0
    products = {}

    loop do
        id = doc.xpath('//*[@id="post-1037"]/div/div/div/div[2]/div/div[4]/ul/li['+productCount.to_s+']').first.first.second.split(" ")[3].split("-")[1]
        url = doc.xpath('//*[@id="post-1037"]/div/div/div/div[2]/div/div[4]/ul/li['+productCount.to_s+']/div[1]/div/div/div/a').first["href"]
        products[id] = url
        totalGrabedCount += 1
        if productCount % 12 == 0
            productCount = 1 
            pageNumber += 1
            file = Curb.open_uri(store.href+"page/#{pageNumber}/")
            doc = Nokogiri::HTML(file).at('body')
        else
            productCount += 1
        end
        break if totalGrabedCount == totalProducts
    end

    products.each_with_index do |item|
        begin
            file = Curb.open_uri(item.second)
            doc = Nokogiri::HTML(file).at('body')
            if(doc.xpath('//*[@id="product-259"]/div[2]/div/form/table/tbody/tr[1]/td[2]').present?)
                # browser.goto store.href
                # byebug
                # doc = Nokogiri::HTML.parse(browser.page_source)
                next
            else
                name = doc.xpath('//*[@id="product-'+item.first+'"]/div[2]/div/h1').text().strip

                sku = doc.xpath('//*[@id="product-'+item.first+'"]/div[2]/div/div[4]/span[1]/span').text().strip
                sku = doc.xpath('//*[@id="product-'+item.first+'"]/div[2]/div/div[3]/span[1]/span').text().strip if sku.eql?("")

                price = doc.xpath('//*[@id="product-'+item.first+'"]/div[2]/div/p[1]/ins/span/bdi').text().strip
                price = doc.xpath('//*[@id="product-'+item.first+'"]/div[2]/div/p[1]/span/bdi').text().strip if price.eql?("")

                qty = doc.xpath('//*[@id="product-'+item.first+'"]/div[2]/div/div[1]').text().strip.split(" ")[0]
                begin
                    brand = doc.xpath('//*[@id="product-'+item.first+'"]/div[2]/div/div[4]/span[2]').children[1].text.strip
                rescue
                    brand = doc.xpath('//*[@id="product-'+item.first+'"]/div[2]/div/div[3]/span[2]').text().split(",")[0].split(" ")[1]
                end    
            end
            puts "Brand: #{brand}, Name: #{name}, SKU: #{sku}, Price: #{price}, QTY: #{qty}"
            add_vargas_turbo_products_to_store(store, name, brand, sku, qty, price)
        rescue
            next
        end
    end
    
end

def add_vargas_turbo_products_to_store(store, title, brand, sku, qty, price)
    latest = store.latest_products.find_or_create_by(sku: sku)
    latest.update(product_title: title, brand: brand, sku: sku, inventory_quantity: qty, price: price)
    latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, sku: sku, inventory_quantity: qty, price: price)
end





