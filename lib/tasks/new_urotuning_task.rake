require 'watir'
require 'webdrivers/chromedriver'
require 'timeout'
require 'uri'
desc 'To scrape inventory urotuningdat'
task new_urotuning_task: :environment do
    store = Store.find_by(store_id: 'urotuning')
    Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
    Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
    raise Exception.new "Browser not found" if !browser.present?
    # --headless
    # browser = Watir::Browser.new :chrome
    browser.goto store.href
    loop do 
        page = 2
        until page.blank?
            url = "#{store.href}?page=#{page}"
            browser.goto url
            products_urls = []
            browser.element(css: '.findify-components-common--grid').children.each do |product|
                products_urls << product.a.href
            end
            _scrape_products(products_urls,browser,store)
            page +=1
        end
    end
    # browser.close
end

def _scrape_products(products_urls,browser,store)
    products_urls.each_with_index do |product, index|
        fitment_array = []
        browser.goto product
        varient_href=product
        data_chunk = product.split("/")[4]
        product_slug=data_chunk.split("?").first
        variant=data_chunk.split("?").last.split("=").last
        title=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/header/h2").text rescue nil
        price=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/div[2]/form/div[1]/div[1]/div/span").text rescue nil
        brand=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/meta[4]").attributes[:content] rescue nil
        mpn=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/meta[5]").attributes[:content] rescue nil
        stock=JSON.parse(browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/div[2]/form/script").text_content).first['inventory_quantity'] rescue nil
        product_id=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[1]/div/div[2]/div/div[2]/form/div[5]").attributes[:data_product_id] rescue nil
        product_data=_add_product_in_store(store, brand, mpn,stock,product_slug,variant,product_id,varient_href,price,title)
        fitments=browser.element(xpath: "/html/body/div[1]/div[2]/main/div[2]/div[2]/div[2]/div[2]/div/div[2]/div[2]/table").children[0].children rescue nil
        if !fitments.blank?
            fitments.each do |fitment| 
                if fitment.text.include?("Audi") || fitment.text.include?("BMW") || fitment.text.include?("Volkswagen")
                    fitment=fitment.text
                    add_in_fitments(product_data.latest_product_id,mpn, fitment,store)
                end  
            end
        end
        puts "===================  #{index}  ==================="
        puts "==== #{title}, #{product_id} ===="
    end
 
end

def add_in_fitments(product_id,mpn,fitment,store)  
    fitments_table =  UroTuningFitment
    fitments_table = fitments_table.find_or_create_by(latest_product_id: product_id, mpn: mpn, fitment: fitment)
end

def _add_product_in_store(store, brand, mpn, stock, slug, variant_id,product_id, href, price, title)
    latest = store.latest_products.find_or_create_by(variant_id: variant_id, product_id: product_id)
    latest.update(brand: brand, mpn: mpn, sku: mpn, inventory_quantity: stock, slug: slug,href: href, price: price, product_title: title)
    latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, sku: mpn,
    inventory_quantity: stock, slug: slug, variant_id: variant_id, product_id: product_id,
    href: href, price: price, product_title: title)
end