require 'watir'
require 'webdrivers/chromedriver'
require 'timeout'
require 'uri'
desc 'To scrape inventory data from mmr_performance'
task cspracing: :environment do
    begin
        store=Store.find_by(store_id: 'cspracing')
        # for local browser
        # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
        # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
        # browser = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --disable-dev-shm-usage --disable-gpu --use-automation-extension=true   '--user-agent=%s' % ua]
        # browser = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
        # for live browser
        Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
        Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
        browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --disable-blink-features=AutomationControlled --use-automation-extension=true   '--user-agent=%s' % ua]
        
        raise Exception.new "Browser not found" if !browser.present?
        retries=0
        begin
            retries ||=0
            browser.goto store.href
            page_number = 0
            until page_number.blank?
                page_number += 1
                url="#{store.href}vehicle-parts/?sort=alphaasc&page=#{page_number}"
                browser.goto url
                begin
                    products=browser.element(xpath: '/html/body/div[2]/div/div[2]/div[1]/div[2]/div/main/form/div/div')
                rescue StandardError => e
                    puts 'Exception throws getting products'
                    sleep 60
                    retry
                end 
                products=products.children       
                if !products.blank?
                    products.each_with_index do |product,index|
                        next if product.attributes[:class]=="border-bt"
                        price=product.children[0].attributes[:data_product_price] rescue nil 
                        sku=product.children[0].attributes[:data_product_sku] rescue nil
                        product_id = product.children[0].attributes[:data_entity_id] rescue nil 
                        title= product.children[0].attributes[:data_name] rescue nil 
                        brand=product.children[0].attributes[:data_product_brand] rescue nil 
                        href=product.children[0].children[0].children[1].children[0].a.href rescue nil
                        product_slug=href.split('/')[3] rescue nil

                        puts "===================  page_number #{page_number}  ==================="
                        product_data=add_product_data_in_store(store, brand,sku,product_slug,product_id,href,price,title)
                        puts "==== #{sku},#{product_id},#{product_slug} ,#{href},#{price},#{title} ===="
                    end
                end
            end
        rescue StandardError => e
            puts "Exception in Parsing Nokogiri::HTML #{e}"
            sleep 1
            retry if (retries += 1) < 3
          end
    rescue Exception => e
        puts e.message
    end
end

def add_product_data_in_store(store, brand, sku, slug, product_id, href, price, title)
    latest = store.latest_products.find_or_create_by(variant_id: product_id, product_id: product_id)
    val=latest.update(brand: brand, mpn: sku, sku: sku, slug: slug,href: href, price: price, product_title: title)
    latest.archive_products.create(store_id: store.id, brand: brand, mpn: sku, sku: sku, slug: slug, variant_id: product_id, product_id: product_id,
    href: href, price: price, product_title: title)
end
