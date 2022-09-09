require 'watir'
require 'webdrivers/chromedriver'
desc 'To scrape data from vivid racing automation watir gem'

task vivid_racing_rake: :environment do
    store = Store.find_by(store_id: 'vividracing')
    urls_str = LoggingTable.where(store_id: store.id).last.url if LoggingTable.where(store_id: store.id).last.present?
    urls = eval(urls_str) if urls_str.present?

    # --headless
    # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
     Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    #for live 
    #Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
    #Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
    
    browser_1=Watir::Browser.new :chrome  , args: %w[--headless --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
    raise Exception.new "Browser 1 not found" if !browser_1.present? 
    
    data=nil
    retry_index=0
    begin 
        retry_index ||=0
        #browser_1.goto urls.present? ? urls[0] : store.href
        browser_1.goto store.href
        puts "--------------------------------------------------------------"
        puts "=========== Browser-1 start== #{browser_1.url} ============"
        #temp = "#{browser_1.url}"
        temp = {}
        temp[0] = "#{browser_1.url}"

        if browser_1.element(xpath: "/html/body/div[2]/div/div[1]/div[3]/div/div[2]/div").present?
            data=browser_1.element(xpath: "/html/body/div[2]/div/div[1]/div[3]/div/div[2]/div")
        else
            data=browser_1.element(xpath: "//div[@class='list-group no-scroll']")
        end
        count = data.children.count
        current_tile = 1

        data.children.each do |item|
            current_tile += 1
            if current_tile == count
                LoggingTable.where(store_id: store.id).destroy_all
            else
                if urls.present?
                    url = urls[1]
                else
                    url=item.attributes[:href] 
                end

                if url.eql?("https://www.vividracing.com/index.php?new=true")
                    puts "---------------------------------------------------------------------"
                    puts " <======================  index page  ==============================>"
                    puts " <==============  page numbers exist in this browser  ==============>"
                    temp[1] = "https://www.vividracing.com/index.php?new=true"
                    get_products(store,url,temp,urls)

                else
                    browser_2=Watir::Browser.new :chrome , args: %w[--headless  --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]

                    raise Exception.new "Browser 2 not found" if !browser_2.present?

                    browser_2.goto url
                    temp[1] = "#{browser_2.url}"

                    if browser_2.elements(xpath: "//*[@class='category-tile']").present?
                        browser_2.elements(xpath: "//*[@class='category-tile']").each do |item|
                            puts "---------------------------------------------"
                            puts "<================other pages================>"
                            prod_url=item.children[0].attributes[:href]
                            get_products(store,prod_url,temp,urls)
                        end
                    end
                    browser_2.close
                end
            end
        end
        browser_1.close
    rescue StandardError => e
        puts "#{e}"
        sleep 10
        retry if (retry_index += 1) < 3
    end
end

def get_products(store,url,temp,urls)
    browser_3=Watir::Browser.new :chrome , args: %w[--headless  --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
    raise Exception.new "Browser 3 not found" if !browser_3.present?           
    begin
        retries ||=0
        page_number = 1
        #browser_3.goto urls[1].present? ? urls[1] : url

        browser_3.goto url
        puts "--------------------------------------------------------------"
        puts "=========== Browser-2 start == #{browser_3.url}============"        

           until page_number.blank? do
                puts "----------------------------------------------------------"
                puts "========= page start ============"
                link=nil
                if url.split("?")[1].eql?("new=true")
                    if urls.present?
                        link = urls[2]
                        page_number = link.split("page=")[1].to_i
                        urls = nil
                        #link =  urls.present? ? urls[2] : "#{url}&page=#{page_number}"    
                    else
                        link = "#{url}&page=#{page_number}"
                        byebug
                    end
                else
                    if urls.present?
                        link = urls[2]
                    else
                        link = "#{url}?page=#{page_number}"
                    end
                end
                #browser_3.goto urls[2].present? ? urls[2] : link
                browser_3.goto link
                temp[2] = "#{browser_3.url}"
                #temp += " | " + "#{browser_3.url}"

                puts "----------------------------------------------------------"
                puts "===========Browser-3 start== #{browser_3.url}============"
                get_products_data(store,browser_3)
                LoggingTable.create!(url: temp, store_id: store.id, page_number: page_number)
                
                puts "=================== #{link} ==========================="
                puts "========= page_number >> #{page_number} end ============"
                puts "---------------------------------------------------------"
                page_number += 1
            end
        #LoggingTable.where(store_id: store.id).last.present
        browser_3.close
    rescue StandardError => e
        puts "#{e}"
        sleep 10
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
        sku=product.children[1].text.split('#')[1] rescue nil
        price = product.children[2].children[0].text rescue nil
        price = price.split(' ')[1].present? ? price.split(' ')[1] : price
      
        if !price.blank?
            price = price.include?(',') || price.include?('$') ? '%.2f' % price.tr('$ ,', '') : '%.2f' % price
        end

        href = product.parent.attributes[:href] rescue nil

        if product.present?
            begin
                browser_4=Watir::Browser.new :chrome , args: %w[--headless  --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
            
                raise Exception.new "Browser not found" if !browser_4.present? 
                browser_4.goto href
                
                brand=browser_4.element(xpath: "/html/body/div[3]/div[4]/div[2]/p[3]/a").text rescue nil 
                if browser_4.element(xpath: "//p[@class='text-success']").present? || browser_4.element(xpath: "//p[@class='text-danger']").present?
                  stock=1
                else
                    stock=0
                end
            browser_4.close
            rescue StandardError => e
                puts "#{e}"
                sleep 10
            end
        end

        puts "================= Brand: #{brand} ====================="
        slug= href.split('/').last.split('.').first rescue nil
        product_id= href.split('/').last.split('.').first.split('-').last rescue nil
        puts "==title>#{title}==sku>#{sku}==price>#{price}==href>#{href}==slug>#{slug}==>productId#{product_id}==stock>#{stock}"
        add_product_data_in_store(store,brand, sku, slug, product_id, href, price, title,stock)
    end   
end
 
def add_product_data_in_store(store,brand, sku, slug, product_id, href, price, title,stock)

    latest = store.latest_products.find_or_create_by(variant_id: product_id, product_id: product_id)
    val=latest.update(mpn: sku, sku: sku, brand: brand,slug: slug,href: href, price: price, product_title: title,inventory_quantity:stock)
    latest.archive_products.create(store_id: store.id, mpn: sku, sku: sku, brand:brand, slug: slug, variant_id: product_id, product_id: product_id,
    href: href, price: price, product_title: title,inventory_quantity:stock)
end