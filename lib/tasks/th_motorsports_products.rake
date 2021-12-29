require 'watir'
require 'webdrivers/chromedriver'
require 'timeout'
desc 'To scrape inventory data from th_motorsports'
task th_motorsports_products: :environment do
    store = Store.find_by(store_id: 'thmotorsports')
    # Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
    # Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
    Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
    Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    browser1 = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
    # --headless
    # browser = Watir::Browser.new :chrome
    browser1.goto store.href

    categories = browser1.element(css: 'body > div.master-wrapper-page > div > div.header-menu > ul').children
    products_urls = []
    @last_visited_page = nil
    @next_page = false

    categories.each_with_index do |list_element, index|
        # byebug
        puts products_urls.count

        list_element.click if !browser1.element(css: '#pager > ul > li.next-page').present?
        scrape_pages(products_urls, browser1)
        if @next_page
            @next_page  = false
            products_urls = []
            redo
        end
    rescue Exception => e
            # browser1.close
            products_urls = []
            redo
            # scrape_pages(products_urls, browser)
    end
end

def scrape_pages products_urls, browser1
    browser2 = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]

    if @last_visited_page.present?
        browser2.goto @last_visited_page
        @last_visited_page = nil
    else
        browser2.goto browser1.url
        browser1.goto browser1.elements(css: '#pager > ul > li.next-page')[0].a.href if browser1.elements(css: '#pager > ul > li.next-page')[0].a.href.present?
    end
    browser2.element(css: '#productsList').children.each do |product|
        products_urls << product.a.href
        if browser2.element(css: '#pager > ul > li.next-page').present? && products_urls.count % 75 == 0
            @last_visited_page = browser2.elements(css: '#pager > ul > li.next-page')[0].a.href
            @next_page = true
            if @next_page
                puts "Last visited page:   #{browser2.url}"
                browser2.close
                scrape_products(products_urls)
            end
            # browser = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
            # browser.goto @last_visited_page
            # byebug
        end
    end
    # byebug
end

def scrape_products products_urls
    browser = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
    products_urls.each_with_index do |product, index|
        fitment_array = []
        browser.goto product

        title = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[1]/div[1]/h1').text
        price = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[2]/div[1]/div[1]/div').text
        manufacturer = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[1]/div[1]/div[2]/span[2]/a').text
        mpn =  browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[2]/div[2]/div[1]').text.split(":")[1]
        
        details = browser.element(xpath: '//*[@id="product-tabs"]/div[1]').text
        if browser.element(xpath: '//*[@id="fitments-show-hide-btn"]').present?
            browser.element(xpath: '//*[@id="fitments-show-hide-btn"]').click
            browser.execute_script("return $('.hidden.fit-row').removeClass('hidden')")
        end

        puts "===================  #{index}  ==================="
        product = add_in_table(mpn, price, title, manufacturer, details)
        puts "==== #{mpn},  #{price},    #{title},    #{manufacturer},   #{details} ===="
        
        fitments = browser.element(xpath: '//*[@id="fitment-accordion"]/div').present? ? browser.element(xpath: '//*[@id="fitment-accordion"]/div').children : nil
        
        # byebug if fitments.blank?
        if !fitments.blank?
            fitments&.each do |fitment|
                if fitment.text.include?("Audi") || fitment.text.include?("BMW") || fitment.text.include?("Volkswagen")
                    fitments_text = fitment.children[1].text
                    add_in_fitments_table(product, mpn, fitments_text)
                end
            end
        end
        if fitments.present?
            # fit = browser.element(xpath: '//*[@id="fitment-accordion"]/div').text
            # fit = fit.split("\n")
            # audi_fts = fit.each_index.select {|i| fit[i].include?("Audi")}
            # bmw_fts = fit.each_index.select{|i| fit[i].include?("BMW")}
            # volkswagen_fts = fit.each_index.select{|i| fit[i].include?("Volkswagen")}
            # byebug
            # audi_fts.each do |index|
            #     byebug
            #     fitments[index].click
            #     byebug
            #     first, *rest = fitments[index].text.split("\n")
            #     rest.each do |f|
            #         fitment_array << f 
            #         @last_visited_index = index
            #     end
            # end
            # bmw_fts.each do |index|
            #     byebug
            #     fitments[index].click
            #     byebug
            #     first, *rest = fitments[index].text.split("\n")
            #     rest.each do |f|
            #         fitment_array << f 
            #         @last_visited_index = index
            #     end
            # end
            # volkswagen_fts.each do |index|
            #     byebug
            #     fitments[index].click
            #     byebug
            #     first, *rest = fitments[index].text.split("\n")
            #     rest.each do |f|
            #         fitment_array << f 
            #         @last_visited_index = index
            #     end
            # end
        end
    end
    # byebug
    puts "Last visited product:   #{browser.url}"
    browser.close
end

def add_in_table(mpn, price, title, manufacturer, details)
    latest = ThmotorsportsProduct
    latest = latest.find_or_create_by(mpn: mpn)
    latest.update(current_price: price, product_title: title, manufacturer: manufacturer, product_details: details)
    latest
end

def add_in_fitments_table(product, mpn, fitments)
    fitments_table = ThmotorsportsProductsFitment
    fitments_table = fitments_table.find_or_create_by(thmotorsports_product_id: product.id, mpn: mpn, fitment: fitments)
end