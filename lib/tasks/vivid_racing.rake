require 'watir'
require 'webdrivers/chromedriver'
desc 'To scrape data from vivid racing automation watir gem'

    $urls = {}
    $temp = {}

    $tile = {}
    $tile_temp = {}

task vivid_racing_rake: :environment do
    store = Store.find_by(store_id: 'vividracing')
    urls_str = LoggingTable.where(store_id: store.id).last.url if LoggingTable.where(store_id: store.id).last.present?
    $urls = eval(urls_str) if urls_str.present?

    tile_str = LoggingTable.where(store_id: store.id).last.temp if LoggingTable.where(store_id: store.id).last.present?
    $tile = eval(tile_str) if tile_str.present?
    # --headless
    # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
    # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    #for live 
     Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
     Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
    
    browser_1=Watir::Browser.new :chrome  , args: %w[--headless --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
    raise Exception.new "Browser 1 not found" if !browser_1.present? 
    
    data=nil
    retry_index=0
    begin 
        retry_index ||=0
        #browser_1.goto $urls.present? ? $urls[0] : store.href
        browser_1.goto store.href
        puts "--------------------------------------------------------------"
        puts "=========== Browser-1 start== #{browser_1.url} ============"
        #$temp = "#{browser_1.url}"
        
        $temp[0] = "#{browser_1.url}"

        if browser_1.element(xpath: "/html/body/div[2]/div/div[1]/div[3]/div/div[2]/div").present?
            data = browser_1.element(xpath: "/html/body/div[2]/div/div[1]/div[3]/div/div[2]/div")
        else
            data = browser_1.element(xpath: "//div[@class='list-group no-scroll']")
        end
        count = data.children.count
        #current_tile = 0
        index = 0
        while index <= count 
            if index == count

                LoggingTable.where(store_id: store.id).destroy_all
            else
                index = $tile[0] if $tile.present?
                $tile_temp[0] = index
                if $urls.present?

                    url = $urls[1]
                else

                    url = data.children[index].attributes[:href]
                end


        
                if url.eql?("https://www.vividracing.com/index.php?new=true")
                    $temp[1] = "https://www.vividracing.com/index.php?new=true"
                    $tile_temp[1] = 0
                    $tile_temp[2] = 0
                    $tile = nil
                    puts "&&&&&&&&&&&&&&&  #{url}  &&&&&&&&&&&&"
                    #get_products(store,url,$temp,$urls)
                    get_products(store,url)
                else
                    browser_2=Watir::Browser.new :chrome , args: %w[--headless  --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
                    raise Exception.new "Browser 2 not found" if !browser_2.present?

                    puts "&&&&&&&&&&&&& #{url} &&&&&&&&&&&&&&&"
                    puts "============ Browser-2 Opening ============="
                    browser_2.goto url
                    puts "&&&&&&&&&&&&& #{browser_2.url} &&&&&&&&&&&&&"
                    $temp[1] = "#{browser_2.url}"


                    row = browser_2.element(xpath: "/html/body/div[3]/div/div[2]").children.count-1
                    i = 3
                    while i < row do 

                        i = $tile[1]+1 if $tile.present?
                        $tile_temp[1] = i
                        
                        puts browser_2.element(xpath: "/html/body/div[3]/div/div[2]").children[i].text

                        tiles_count_in_row = browser_2.element(xpath: "/html/body/div[3]/div/div[2]").children[i].children.count
                        
                        j = 0
                        while j < tiles_count_in_row do
                            if $tile.present?

                                j = $tile[2]+1
                                $tile = nil 
                            end

                            $tile_temp[2] = j

                            if browser_2.element(xpath: "/html/body/div[3]/div/div[2]").children[i].children[j].text.present?
                                puts browser_2.element(xpath: "/html/body/div[3]/div/div[2]").children[i].children[j].text
                                
                                if browser_2.element(xpath: "/html/body/div[3]/div/div[2]").children[i].children[j].children[0].children[0].present?
                                    prod_url = browser_2.element(xpath: "/html/body/div[3]/div/div[2]").children[i].children[j].children[0].children[0].attributes[:href]
                                    get_products(store, prod_url)
                                end
                            end
                            j+=1
                        end
                        i+=1
                    end


                    # if browser_2.elements(xpath: "//*[@class='category-tile']").present?
                    #     browser_2.elements(xpath: "//*[@class='category-tile']").each do |item|
                    #         puts "---------------------------------------------"
                    #         puts "<================other pages================>"
                    
                    #         prod_url = item.children[0].attributes[:href]
                    
                    #         #get_products(store,prod_url,$temp,$urls)
                    #         #get_products(store,prod_url)
                    #     end
                    # end
                    browser_2.close
                end
            end
            index+=1
        end

        browser_1.close
    rescue StandardError => e
        puts "#{e}"
        sleep 10
        retry if (retry_index += 1) < 3
    end
end

def get_products(store,url)
#def get_products(store,url,$temp,$urls)
    browser_3=Watir::Browser.new :chrome , args: %w[--headless  --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
    raise Exception.new "Browser 3 not found" if !browser_3.present?           
    begin
        retries ||=0
        #page_number = 1
        last_page = LoggingTable.where(store_id: store.id).last.page_number if LoggingTable.where(store_id: store.id).last.present?
        
        if last_page.present?
            page_number = last_page
            last_page = nil
        else
            page_number = 1
        end

        #browser_3.goto $urls[1].present? ? $urls[1] : url
        puts "&&&&&&&&&&&&& #{url} &&&&&&&&&&&&&&&"
        puts "============ Browser-3 Opening ============="
        browser_3.goto url
        puts "&&&&&&&&&&&&& #{browser_3.url} &&&&&&&&&&&&&&&"

        puts "--------------------------------------------------------------"
        puts "=========== Browser-2 start == #{browser_3.url}============"        

           until page_number.blank? do
                puts "----------------------------------------------------------"
                puts "========= page start ============"
                link=nil
                if url.split("?")[1].eql?("new=true")
                    if $urls.present?
                        link = $urls[2]
                        #page_number = link.split("page=")[1].to_i
                        puts link
                        $urls = nil
                        #link =  $urls.present? ? $urls[2] : "#{url}&page=#{page_number}"    
                    else
                        puts link
                        link = "#{url}&page=#{page_number}"
                        puts link
                    end
                else
                    if $urls.present?
                        link = $urls[2]
                        #page_number = link.split("page=")[1].to_i
                        $urls = nil
                    else
                        link = "#{url}?page=#{page_number}"
                    end
                    puts link
                end
                #browser_3.goto $urls[2].present? ? $urls[2] : link
                puts link

                puts "&&&&&&&&&&&&& #{link} &&&&&&&&&&&&&&&"
                puts "============ Browser-3 Opening ============="
                browser_3.goto link
                puts "&&&&&&&&&&&&& #{browser_3.url} &&&&&&&&&&&&&&&"

                if browser_3.element(xpath: "/html/body/div[3]/div/div[2]/h1[2]").present?
                    if browser_3.element(xpath: "/html/body/div[3]/div/div[2]/h1[2]").text.eql?("No products found")
                        break
                    end
                end
                $temp[2] = "#{browser_3.url}"
                #$temp += " | " + "#{browser_3.url}"

                puts "----------------------------------------------------------"
                puts "===========Browser-3 start== #{browser_3.url}============"
                get_products_data(store,browser_3)

                LoggingTable.create!(url: $temp, store_id: store.id, page_number: page_number, temp: $tile_temp)
                
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

    products_data = browser.elements(xpath: "//*[@class='product-info']") 
    if !products_data.present?
        browser.close
    end
    products_data.each do |product|
        brand = nil  
        title = product.children[0].text rescue nil
        sku = product.children[1].text.split('#')[1] rescue nil
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
                #brand = browser_4.element(xpath: "/html/body/div[3]/div[4]/div[2]/p[3]/a").text rescue nil 
                brand = browser_4.element(xpath: "/html/body/div[3]/div[4]").children[1].children[6].text rescue nil
                #byebug if brand == nil
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