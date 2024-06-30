require 'watir'
require 'webdrivers/chromedriver'
require 'rtesseract'
require 'api_2captcha'
desc 'To scrape bc racing products using automation watir gem'
task bc_racing_products: :environment do
  def select_first_available_date(browser)
    # Wait for the date picker to appear
    sleep 1
    all_slots = browser.element(css: 'body > div.datepicker.datepicker-dropdown.dropdown-menu.datepicker-orient-left.datepicker-orient-top > div.datepicker-days').children[0].children[1]
    slots_new = []
    all_slots.children.each do |slots|
      slots_new << slots.collect{|s| s}
      slots_new = slots_new.flatten
    end
    slots_new.each do |slot|
      sleep 1
      puts slot.text
      if !slot.attributes[:title].eql?("Not Allowed") && !slot.attributes[:title].eql?("Slots Full") && !slot.attributes[:title].eql?("Off Day")
        slot.click
      end
    end
  end


  puts "I'm in"
  # store = Store.find_by(name: 'bcracing')
  
  # Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
  # Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH'] 

  # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
  Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
  

  client =  Api2Captcha.new("6fc6e7e9ff29bacf040d24bc65f5c9ee")

  # browser = Watir::Browser.new :chrome
  begin
    # browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu ]
    proxies = [
    '192.168.1.100:8080',
    '192.168.1.101:8080',
    '192.168.1.102:8080'
    ]

    ip, port = proxies[0].split(':')
    
    browser_options = {
      proxy: {
        http: proxies[0],
        ssl: proxies[0]
      }
    }
  
    browser=Watir::Browser.new :chrome, options: browser_options , args: %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized]

  # Navigate to Page
    browser.goto "https://pak.blsspainvisa.com/appointment.php"
    browser.element(xpath: '//*[@id="popup"]/div/div/div[1]/a').click
    # byebug
    loop do
      if browser.element(xpath: '//*[@id="verification_code"]').exists?
        sleep 2
      else
        break
      end
    end
    browser.execute_script('window.scrollBy(0, 400)')
    browser.execute_script('window.scrollBy(0, 400)')
    browser.element(xpath: '//*[@id="pakFirst"]/section/div/div/div/div[3]/div[1]/button').click
    browser.element(xpath: '//*[@id="app_date"]').click;
    select_first_available_date(browser)
    dropdown = browser.element(xpath: '//*[@id="app_time"]')
    available_options = dropdown.options.reject { |option| option.text.empty? }
    if available_options.any?
      available_options.each { |option| puts "Available slot: #{option.text}" }  # Print available slots for verification
      dropdown.select(available_options.first.text)
      puts "Selected slot: #{available_options.first.text}"
    else
      puts "No available options to select."
    end
    byebug
    browser.execute_script('window.scrollBy(0, 400)')
    browser.execute_script('window.scrollBy(0, 400)')
    captcha = browser.element(xpath: '//*[@id="captcha-img"]')
    browser.screenshot.save("test.png")
    puts captcha.inspect
    image = File.open("~/Desktop/test.png", "r")
    result = client.normal({ image: image.source })
    # # OR
    # result = client.normal({
    # image: 'https://site-with-captcha.com/path/to/captcha.jpg'
    # })
    text = image.to_s
    puts text

    # raise Exception.new "Browser error" if !browser.present?
  rescue Exception=> e
    puts e.message
    UserMailer.with(user: e, script: "bc_racing_products").issue_in_script.deliver_now
  end


    # Authenticate and Navigate to the store
  # browser.text_field(xpath: '//*[@id="email"]').set 'orders@moddedeuros.com'
  # browser.text_field(xpath: '//*[@id="password"]').set 'u{U8$qz/S3&)TN9h'
  # browser.button(xpath: '//*[@id="Submit"]').click
  # browser.link(xpath: '//*[@id="form1"]/div[3]/div[3]/div[1]/div[2]/table/tbody/tr[2]/td[2]/a[1]').click
  # browser.link(xpath: '//*[@id="ContentPlaceHolder1_formTable"]/tbody/tr[3]/td[4]/a').click
  # page = 1
  # page_number = 1
  # until page.blank?
  #   rows = browser.table(id:'allItems').trs
  #   puts "\n ************************************** Page: #{page_number} **************************************"
  #   rows.each do |row|
  #     mpn = ""
  #     des = ""
  #     price = ""
  #     stock_text = ""
  #     row.each_with_index do |col, index|
  #       mpn = col.text if index == 2
  #       des = col.text if index == 3
  #       price = col.text if index == 5
  #       stock_text = col.text if index == 11
  #     end
  #     next if mpn.present? and !mpn.include? '-'
  #     next if price.blank?
  #     qty = stock_text.split('(').last.split(')').first.to_i if stock_text.present?
  #     puts "mpn=#{mpn} des=#{des} price=#{price} qty=#{qty}"
  #     add_bc_racing_products_to_store(store, des, mpn, qty, price)
  #   end

  #   if browser.link(xpath: '//*[@id="ContentPlaceHolder1_ItemListPager_lnkNextPage"]').present?
  #     browser.link(xpath: '//*[@id="ContentPlaceHolder1_ItemListPager_lnkNextPage"]').click
  #     page_number += 1
  #   else
  #     page = nil
  #   end
  # end
  # browser.close
end

def add_bc_racing_products_to_store(store, title, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: 'BC Racing', mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: 'BC Racing', mpn: mpn, inventory_quantity: qty, price: price)
end