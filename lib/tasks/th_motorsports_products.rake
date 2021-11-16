require 'watir'
require 'webdrivers/chromedriver'
require 'timeout'
desc 'To scrape inventory data from th_motorsports'
task th_motorsports_products: :environment do
    store = Store.find_by(store_id: 'thmotorsports')
    Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
    Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
    # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
    # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    browser = Watir::Browser.new :chrome, args: %w[ --no-sandbox --disable-blink-features=AutomationControlled --use-automation-extension=true --exclude-switches=enable-automation --ignore-certificate-errors '--user-agent=%s' % ua]
    # browser = Watir::Browser.new :chrome
    browser.goto store.href

    categories = browser.element(css: 'body > div.master-wrapper-page > div > div.header-menu > ul').children
    products_urls = []
    @last_visited_page = nil
    @next_page = false
    Thread.handle_interrupt(Timeout::Error => :never) {
        timeout(10){
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
    end
ensure
    # byebug
    browser.goto @last_visited_page
    # browser
    scrape_pages(products_urls, browser)
end

def scrape_pages products_urls, browser 
    if @last_visited_page.present?
        # browser.goto @last_visited_page
        @last_visited_page = nil
    end
    browser.element(css: '#productsList').children.each do |product|
        products_urls << product.a.href
        if browser.element(css: '#pager > ul > li.next-page').present? && products_urls.count % 75 == 0
            @last_visited_page = browser.elements(css: '#pager > ul > li.next-page')[0].a.href
            browser.elements(css: '#pager > ul > li.next-page')[0].a.click
            @next_page == true
        end
    end
end