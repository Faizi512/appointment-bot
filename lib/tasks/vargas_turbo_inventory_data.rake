require 'watir'
require 'webdrivers/chromedriver'

desc 'To scrap inventory data from Vargas Turbo using watir'
task :vargas_turbo => :environment do
    store = Store.find_by(name: 'vargas_turbo')
    

    Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH']
    Selenium::WebDriver::Chrome::Service.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
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
            if( doc.at('.variations').present?)
                browser.goto item[1]

                name = doc.at("//h1[@itemprop='name']").text.strip
                brand = doc.at('.posted_in').children[1].text.strip
                selectorCount = browser.divs(class: "avada-select-parent").count

                browser.divs(class: "avada-select-parent")[0].child.options.each_with_index do |option, index|

                    if index == 0
                        next
                    else
                        option.click

                        if selectorCount == 2
                            browser.divs(class: "avada-select-parent")[0].options.each_with_index do |innerOption, innerIndex|
                                if innerIndex == 0
                                    next
                                else
                                    price_temp = browser.divs(class: "woocommerce-variation-price")[0].text
                                    price = price_temp.split(" ")[0] if price_temp.include?(" ")
                                    qty = browser.divs(class: "woocommerce-variation-availability")[0].text.split(" ")[0]
                                    sku = browser.divs(class: "product_meta")[0].child.text.split(":")[1].strip
                                    variant_id = browser.elements(class: "variation_id")[0].attribute_value("value")

                                    puts "Brand: #{brand}, Name: #{name}, SKU: #{sku}, Price: #{price}, QTY: #{qty}, Variant id: #{variant_id}"
                                    add_vargas_turbo_products_to_store(store, name, brand, sku, qty, price, variant_id)
                                end
                            end
                        else
                            price_temp = browser.divs(class: "woocommerce-variation-price")[0].text
                            price = price_temp.split(" ")[0] if price_temp.include?(" ")
                            qty = browser.divs(class: "woocommerce-variation-availability")[0].text.split(" ")[0]
                            sku = browser.divs(class: "product_meta")[0].child.text.split(":")[1].strip
                            variant_id = browser.elements(class: "variation_id")[0].attribute_value("value")

                            puts "Brand: #{brand}, Name: #{name}, SKU: #{sku}, Price: #{price}, QTY: #{qty}, Variant id: #{variant_id}"
                            add_vargas_turbo_products_to_store(store, name, brand, sku, qty, price, variant_id)
                        end
                    end
                end
            else
                name = doc.at("//h1[@itemprop='name']").text.strip
                sku = doc.at('.sku').text.strip
                price_temp = doc.at('.price').text.strip
                price = price_temp.split(" ")[0] if price_temp.include?(" ")
                qty = doc.at('.stock').text.split(" ")[0]
                brand = doc.at('.posted_in').children[1].text.strip

                puts "Brand: #{brand}, Name: #{name}, SKU: #{sku}, Price: #{price}, QTY: #{qty}"
                add_vargas_turbo_products_to_store(store, name, brand, sku, qty, price, nil)
            end
        rescue
            next
        end
    end
    
end

def add_vargas_turbo_products_to_store(store, title, brand, sku, qty, price, variant_id)
    latest = store.latest_products.find_or_create_by(sku: sku)
    latest.update(product_title: title, brand: brand, sku: sku, inventory_quantity: qty, price: price, variant_id: variant_id)
    latest.archive_products.create(store_id: store.id, product_title: title, brand: brand, sku: sku, inventory_quantity: qty, price: price, variant_id: variant_id)
end