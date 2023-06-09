require 'watir'
require 'webdrivers/chromedriver'
require 'timeout'
require 'uri'
require 'skylight'
Skylight.start!

desc 'To scrape inventory urotuning data'

Skylight.instrument(title: 'new_urotuning span') do
    task new_urotuning_task: :environment do
        begin
            store = Store.find_by(store_id: 'urotuning')
            # for local browser
            # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
            # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
            # browser = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
            # # for live browser
            Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
            Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
            browser = Watir::Browser.new :chrome, args: %w[ --headless --no-sandbox --disable-dev-shm-usage --disable-gpu ]
            raise Exception.new "Browser not found" if !browser.present?
            browser.goto store.href
            total_product = browser.element(xpath: '//*[@id="collection-contianer"]/div[3]/div/div[1]/div[1]/div/button[1]/span[2]').text.gsub("(","").gsub(")", "").to_i
            raise Exception.new "Data not found" if !total_product.present? 
            offset=UrotuningFtimentsPageLog.last.present? ? UrotuningFtimentsPageLog.last['offset'].to_i : 0
            # offset=51840
            while offset <= total_product do  
                add_offsets(offset,total_product)
                puts "=====================#{offset}================"
                url = "#{store.href}?offset=#{offset}"
                retries =0
                begin 
                    retries ||=0
                    browser.goto url
                    products_urls = []
                    products=browser.element(css: '.findify-components-common--grid') 
                    products=products.children 
                    if !products.blank?
                        products.each do |product|
                            products_urls << product.a.href
                        end
                    end
                rescue StandardError => e
                    puts "Exception in Parsing Nokogiri::HTML #{e}"
                    sleep 1
                    retry if (retries += 1) < 3
                end

                _scrape_products(products_urls,browser,store)
                offset +=24
            end
        rescue Exception => e
            puts e.message
        end
    end

    def _scrape_products(products_urls,browser,store)
        products_urls.each_with_index do |product, index|
            fitment_array = []
            retries = 0
            begin
                retries ||= 0
                browser.goto product
            rescue StandardError => e
                puts "Exception #{e}"
                sleep 10
                next if (retries += 1) < 3
            end
            varient_href=product
            data_chunk = product.split("/")[4]
            product_slug=data_chunk.split("?").first
            variant=data_chunk.split("?").last.split("=").last
            title=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/header/h2").text rescue nil
            if (browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/div[2]/form/div[1]/div[1]/div/span").exists? == true )
                price_data=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/div[2]/form/div[1]/div[1]/div/span").text 
                price = price_data.include?(',') || price_data.include?('$') ? '%.2f' % price_data.tr('$ ,','') : '%.2f' % price_data
            else
                price = "0"
            end
            brand=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/meta[4]").attributes[:content] rescue nil
            mpn=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/meta[5]").attributes[:content] rescue nil
            stock=JSON.parse(browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/div[2]/form/script").text_content).first['inventory_quantity'] rescue nil
            product_id=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/div[2]/form/div[5]").attributes[:data_product_id] rescue nil
            product_data=_add_product_in_store(store, brand, mpn,stock,product_slug,variant,product_id,varient_href,price,title)
            if (browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[2]/div/div[2]/div[2]/table").exists? == true )
                fitments=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[2]/div/div[2]/div[2]/table") rescue nil
                fitments =fitments.children[0].children  rescue nil
                if !fitments.blank?
                    fitments.each do |fitment| 
                        if fitment.text&.include?("Audi") || fitment.text.include?("BMW") || fitment.text.include?("Volkswagen") || fitment.text.include?("MINI") || fitment.text.include?("Mercedes Benz") ||  fitment.text.include?("Porsche") ||  fitment.text.include?("Other Models")
                            fitment=fitment.text
                            add_in_fitments(product_data.latest_product_id,product_data.product_id,mpn, fitment,store)
                        end  
                    end
                end
            end 
            puts "===================  #{index}  ==================="
            puts "==== #{title},#{mpn},#{stock},#{product_slug},#{variant},#{product_id}, #{varient_href},#{price},#{title} ===="
        end
    end

    def add_in_fitments(latest_product_id,product_id,mpn,fitment,store)  
        fitments_table =  UroTuningFitment
        fitments_table = fitments_table.find_or_create_by(latest_product_id: latest_product_id, product_id: product_id, mpn: mpn, fitment: fitment)
    end

    def add_offsets(offset,total_product) 
        new_offset=0
        offset_table =  UrotuningFtimentsPageLog
        if(offset+24 >= total_product)
                UrotuningFtimentsPageLog.destroy_all
                new_offset=UrotuningFtimentsPageLog.last.present? ? UrotuningFtimentsPageLog.last['offset'].to_i : 0
                offset_table = offset_table.find_or_create_by(offset: new_offset)
        else
            offset_table = offset_table.find_or_create_by(offset: offset)
        end 
    end

    def _add_product_in_store(store, brand, mpn, stock, slug, variant_id,product_id, href, price, title)
        latest = store.latest_products.find_or_create_by(variant_id: variant_id, product_id: product_id)
        val=latest.update(brand: brand, mpn: mpn, sku: mpn, inventory_quantity: stock, slug: slug,href: href, price: price, product_title: title)
        latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, sku: mpn,
        inventory_quantity: stock, slug: slug, variant_id: variant_id, product_id: product_id,
        href: href, price: price, product_title: title)
    end
end