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
    browser = Watir::Browser.new :chrome, args: %w[--no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
    # --headless
    # browser = Watir::Browser.new :chrome
    browser.goto store.href
    # byebug
    categories = browser.element(css: 'body > div.master-wrapper-page > div > div.header-menu > ul').children
    products_urls = []
    @last_visited_page = nil
    @next_page = false
    Thread.handle_interrupt(Timeout::Error => :never) {
        Timeout.timeout(10){
            categories.each_with_index do |list_element, index|
                puts products_urls.count
                list_element.click if !browser.element(css: '#pager > ul > li.next-page').present?
                scrape_pages(products_urls, browser )
                if @next_page
                    @next_page = false
                    redo
                end
                # title = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[1]/div[1]/h1').text
                # price = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[2]/div[1]/div[1]/div').text
                # manufacturer = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[1]/div[1]/div[2]/span[2]/a').text
                # mpn =  browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[2]/div[2]/div[1]').text.split(":")[1]
            end
          # Timeout::Error doesn't occur here
          Thread.handle_interrupt(Timeout::Error => :on_blocking) {
            # possible to be killed by Timeout::Error
            # while blocking operation
          }
        }
      }
rescue Exception => e
    # byebug
    if Timeout::Error.new.is_a?(StandardError)
        # scrape_pages(products_urls, browser)
        # redo
        # scrape_products products_urls, browser
    end
# ensure
#     byebug
#     browser.goto @last_visited_page
    #  browser
#     byebug
#     scrape_products products_urls, browser
    # scrape_pages(products_urls, browser)
end

def scrape_pages products_urls, browser 
    # byebug
    if @last_visited_page.present?
        # byebug
        # browser.goto @last_visited_page
        @last_visited_page = nil
    end
    browser.element(css: '#productsList').children.each do |product|
        products_urls << product.a.href
        if browser.element(css: '#pager > ul > li.next-page').present? && products_urls.count % 75 == 0
            # byebug
            @last_visited_page = browser.elements(css: '#pager > ul > li.next-page')[0].a.href
            @next_page = true
            if @next_page
                scrape_products(products_urls, browser)
            end
            browser.goto @last_visited_page
        end
    end
    # byebug
end

def scrape_products products_urls, browser 
    # byebug
    products_urls.each_with_index do |product, index|
        @last_visited_page = product
        @last_visited_index = nil
        fitment_array = []
        browser.goto product
        title = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[1]/div[1]/h1').text
        price = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[2]/div[1]/div[1]/div').text
        manufacturer = browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[1]/div[1]/div[2]/span[2]/a').text
        mpn =  browser.element(xpath: '//*[@id="product-details-form"]/div/div[1]/div[2]/div[2]/div[1]').text.split(":")[1]
        details = browser.element(xpath: '//*[@id="product-tabs"]/div[1]').text
        if browser.element(xpath: '//*[@id="fitments-show-hide-btn"]').present?
            browser.element(xpath: '//*[@id="fitments-show-hide-btn"]').click
        end
        fitments = browser.element(xpath: '//*[@id="fitment-accordion"]/div').children
        # fit = browser.element(xpath: '//*[@id="fitment-accordion"]/div').text
        # fit = fit.split("\n")
        # ft =  fit.each_index.select{|i| fit[i].include?("Audi") || fit[i].include?("Volkswagen") || fit[i].include?("BMW")}
        # byebug
        # ft.each do |index|
        #     fitments[index].click
        #     first, *rest = fitments[index].text.split("\n")
        #     rest.each do |f|
        #         fitment_array << f
        #     end
        #     @last_visited_index = index
        # end
        # byebug
        add_in_table(mpn, price, title, manufacturer, details, fitments)
        puts "====#{mpn},  #{price},    #{title},    #{manufacturer},   #{details}, fitments count: #{fitments.count} ===="
    end
end

def add_in_table(mpn, price, title, manufacturer, details, fitments)
    latest = ThmotorsportsProduct
    latest = latest.find_or_create_by(mpn: mpn)
    latest.update(current_price: price, product_title: title, manufacturer: manufacturer, product_details: details)
end