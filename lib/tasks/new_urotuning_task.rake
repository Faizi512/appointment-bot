require 'watir'
require 'webdrivers/chromedriver'
require 'timeout'
require 'uri'
desc 'To scrape inventory urotuning data'
task new_urotuning_task: :environment do
    begin
        store = Store.find_by(store_id: 'urotuning')
        # for local browser
        # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
        # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
        # browser = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
        # for live browser
        Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
        Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
        browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu ]

        # browser = Watir::Browser.new :chrome
        raise Exception.new "Browser not found" if !browser.present?
        browser.goto store.href
        total_product=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[3]/div/div[2]/div[4]/div[2]/span").text.split.last.to_i 
        raise Exception.new "Data not found" if !total_product.present? 
        last_offset=UrotuningFtimentsPageLog.last.present? ? UrotuningFtimentsPageLog.last['offset'].to_i : 0
        if(last_offset == 0)
          offset = last_offset
        elsif(last_offset < total_product)
           offset = last_offset
        elsif(last_offset == total_product)
            UrotuningFtimentsPageLog.destroy_all
            offset = 0
        else 
            offset = 0
        end
        while offset <= total_product do  
            add_offsets(offset)
            puts "=====================#{offset}================"
            url = "#{store.href}?offset=#{offset}"
            browser.goto url
            products_urls = []
            products=browser.element(css: '.findify-components-common--grid') rescue nil
            products=products.children 
            if !products.blank?
                products.each do |product|
                    products_urls << product.a.href
                end
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
            retry if (retries += 1) < 3
        end
        # product="https://www.urotuning.com/products/apr-high-performance-ignition-coils?variant=40332676956353"
        # browser.goto product
        varient_href=product
        data_chunk = product.split("/")[4]
        product_slug=data_chunk.split("?").first
        variant=data_chunk.split("?").last.split("=").last
        title=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/header/h2").text rescue nil
        price_data=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/div[2]/form/div[1]/div[1]/div/span").text rescue nil
        price = price_data.include?('$') ? '%.2f' % price_data.split('$')[1] : '%.2f' % price_data
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
                    if fitment.text.include?("Audi") || fitment.text.include?("BMW") || fitment.text.include?("Volkswagen") || fitment.text.include?("MINI") || fitment.text.include?("Mercedes Benz") ||  fitment.text.include?("Porsche") ||  fitment.text.include?("Other Models")
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

def add_offsets(offset)  
    offset_table =  UrotuningFtimentsPageLog
    offset_table = offset_table.find_or_create_by(offset: offset)
end

def _add_product_in_store(store, brand, mpn, stock, slug, variant_id,product_id, href, price, title)
    latest = store.latest_products.find_or_create_by(variant_id: variant_id, product_id: product_id)
    val=latest.update(brand: brand, mpn: mpn, sku: mpn, inventory_quantity: stock, slug: slug,href: href, price: price, product_title: title)
    latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, sku: mpn,
    inventory_quantity: stock, slug: slug, variant_id: variant_id, product_id: product_id,
    href: href, price: price, product_title: title)
end