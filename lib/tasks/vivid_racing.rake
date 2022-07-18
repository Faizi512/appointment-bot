require 'watir'
require 'webdrivers/chromedriver'
desc 'To scrape data from vivid racing automation watir gem'

task vivid_racing_rake: :environment do
    store = Store.find_by(store_id: 'vividracing')
    # --headless
    # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
    # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    #for live 
    Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
    Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
    browser_1=Watir::Browser.new :chrome, args: %w[--headless --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
    raise Exception.new "Browser not found" if !browser_1.present? 

    data=nil
    retry_index=0
    begin 
        retry_index ||=0
        browser_1.goto store.href
        if browser_1.element(xpath: "/html/body/div[2]/div/div[1]/div[3]/div/div[2]/div").present?
            data=browser_1.element(xpath: "/html/body/div[2]/div/div[1]/div[3]/div/div[2]/div")
        else
            data=browser_1.element(xpath: "//div[@class='list-group no-scroll']")
        end
        data.children.each do |item|
            url=item.attributes[:href]
            if url.eql?("https://www.vividracing.com/index.php?new=true")
                puts " <================index page================>"
                # get_products(store,url)
            else
                browser_2=Watir::Browser.new :chrome, args: %w[--headless --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
                raise Exception.new "Browser not found" if !browser_2.present?
                browser_2.goto url
                if browser_2.elements(xpath: "//*[@class='category-tile']").present?
                    browser_2.elements(xpath: "//*[@class='category-tile']").each do |item|
                        puts "<================other pages================>"
                        prod_url=item.children[0].attributes[:href]
                        get_products(store,prod_url)
                    end
                end
                browser_2.close
            end
        end
        browser_1.close
    rescue StandardError => e
        puts "#{e}"
        sleep 60
        retry if (retry_index += 1) < 3
    end
end

def get_products(store,url)
    browser_3=Watir::Browser.new :chrome, args: %w[--headless --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
    raise Exception.new "Browser not found" if !browser_3.present?           
    begin
        retries ||=0
        browser_3.goto url
        page_number = 1
        until page_number.blank? do
            
            if url.split("?")[1].eql?("new=true") 
                link = "#{url}&page=#{page_number}"
            else
                link = "#{url}?page=#{page_number}"
            end
            browser_3.goto link
            get_products_data(store,browser_3)
            page_number += 1
        end
        browser_3.close
    rescue StandardError => e
        puts "#{e}"
        sleep 60
        retry if (retries += 1) < 3
    end
end

def get_products_data(store,browser) 
    products_data=browser.elements(xpath: "//*[@class='product-info']") 
    if !products_data.present?
        browser.close
    end
    products_data.each do |product|
        brand=nil  
        title=product.children[0].text rescue nil
        sku=product.children[1].text.split(' ')[1] rescue nil
        price=product.children[2].children[0].text rescue nil
        price=price.split(' ')[1].present? ? price.split(' ')[1] : price
        if !price.blank?
            price = price.include?(',') || price.include?('$') ? '%.2f' % price.tr('$ ,', '') : '%.2f' % price
        end
        href=product.parent.attributes[:href] rescue nil
        if product.present?
            browser_4=Watir::Browser.new :chrome, args: %w[--headless --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
            raise Exception.new "Browser not found" if !browser_4.present? 
            browser_4.goto href
            brand=browser_4.element(xpath: "/html/body/div[3]/div[2]/div[2]/p[3]/a").text rescue nil 
            browser_4.close
        end
        puts "===================#{brand}============="
        slug= href.split('/').last.split('.').first rescue nil
        product_id= href.split('/').last.split('.').first.split('-').last rescue nil
        puts "====title#{title}==sku#{sku}==price#{price}==href#{href}==slug#{slug}==productId#{product_id}"
        add_product_data_in_store(store,brand, sku, slug, product_id, href, price, title)
    end   
end
 
def add_product_data_in_store(store,brand, sku, slug, product_id, href, price, title)
    latest = store.latest_products.find_or_create_by(variant_id: product_id, product_id: product_id)
    val=latest.update(mpn: sku, sku: sku,brand: brand,slug: slug,href: href, price: price, product_title: title)
    latest.archive_products.create(store_id: store.id, mpn: sku, sku: sku,brand:brand,slug: slug, variant_id: product_id, product_id: product_id,
    href: href, price: price, product_title: title)
end