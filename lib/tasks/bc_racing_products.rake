require 'watir'
require 'webdrivers/chromedriver'
desc 'To scrape bc racing products using automation watir gem'
task bc_racing_products: :environment do
  puts "I'm in"
  store = Store.find_by(name: 'bcracing')
  
  Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
  Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH'] 

  # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
  # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
  # browser = Watir::Browser.new :chrome
  begin
    browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu ]
    # browser = Watir::Browser.new :chrome

  # Navigate to Page
    browser.goto store.href
    raise Exception.new "Browser error" if !browser.present?
  rescue Exception=> e
    puts e.message
    UserMailer.with(user: e, script: "bc_racing_products").issue_in_script.deliver_now
  end
    # Authenticate and Navigate to the store
  browser.text_field(xpath: '//*[@id="email"]').set 'orders@moddedeuros.com'
  browser.text_field(xpath: '//*[@id="password"]').set 'u{U8$qz/S3&)TN9h'
  browser.button(xpath: '//*[@id="Submit"]').click
  browser.link(xpath: '//*[@id="form1"]/div[3]/div[3]/div[1]/div[2]/table/tbody/tr[2]/td[2]/a[1]').click
  # browser.link(xpath: '//*[@id="ContentPlaceHolder1_formTable"]/tbody/tr[3]/td[4]/a').click
  page = 1
  page_number = 1
  until page.blank?
    rows = browser.table(id:'allItems').trs
    puts "\n ************************************** Page: #{page_number} **************************************"
    rows.each do |row|
      mpn = ""
      des = ""
      price = ""
      stock_text = ""
      row.each_with_index do |col, index|
        mpn = col.text if index == 2
        des = col.text if index == 3
        price = col.text if index == 5
        stock_text = col.text if index == 11
      end
      next if mpn.present? and !mpn.include? '-'
      next if price.blank?
      qty = stock_text.split('(').last.split(')').first.to_i if stock_text.present?
      puts "mpn=#{mpn} des=#{des} price=#{price} qty=#{qty}"
      add_bc_racing_products_to_store(store, des, mpn, qty, price)
    end

    if browser.link(xpath: '//*[@id="ContentPlaceHolder1_ItemListPager_lnkNextPage"]').present?
      browser.link(xpath: '//*[@id="ContentPlaceHolder1_ItemListPager_lnkNextPage"]').click
      page_number += 1
    else
      page = nil
    end
  end
  browser.close
end

def add_bc_racing_products_to_store(store, title, mpn, qty, price)
  latest = store.latest_products.find_or_create_by(mpn: mpn)
  latest.update(product_title: title, brand: 'BC Racing', mpn: mpn, inventory_quantity: qty, price: price)
  latest.archive_products.create(store_id: store.id, product_title: title, brand: 'BC Racing', mpn: mpn, inventory_quantity: qty, price: price)
end