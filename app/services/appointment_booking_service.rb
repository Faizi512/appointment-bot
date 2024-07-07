# app/services/appointment_booking_service.rb

require 'watir'
require 'webdrivers/chromedriver'
require 'rtesseract'
require 'api_2captcha'

class AppointmentBookingService
  attr_reader :batch, :errors

  def initialize(batch)
    # byebug
    @batch = batch
    @errors = []
  end

  def call
    threads = []
    batch.each do |customer|
      threads << Thread.new do
        book_appointment(customer)
      end
    end

    # Wait for all threads to complete
    threads.each(&:join)
  end

  private

  def book_appointment(customer)
    # byebug
    # Example booking logic - adjust this to your needs
    
    puts "I'm in"
    driver = Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"


    client =  Api2Captcha.new("6fc6e7e9ff29bacf040d24bc65f5c9ee")
    first = true
    second = true
    third = true
    is_slot_done = false
    retrying = false
    # browser = Watir::Browser.new :chrome
    begin
      # browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu ]
      proxies = [
      '192.168.1.100:8080',
      '192.168.1.101:8080',
      '192.168.1.102:8080'
      ]
      n = Random.rand(0..2)
      ip, port = proxies[n].split(':')
      
      browser_options = {
        proxy: {
          http: proxies[n],
          ssl: proxies[n]
        }
      }
    
      browser=Watir::Browser.new :chrome, options: browser_options , args: %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized]

      # Navigate to Page
      browser.goto "https://pak.blsspainvisa.com/appointment.php"
      browser.element(xpath: '//*[@id="popup"]/div/div/div[1]/a').click
      browser.text_field(xpath: '//*[@id="email"]').set customer.email
      # browser.text_field(xpath: '//*[@id="phone"]').set customer.phone
      # #byebug
      wait_for_otp = false
      loop do
        if browser.element(xpath: '//*[@id="verification_code"]').exists?
          if customer.is_family?
            browser.element(xpath: '//*[@id="app_type2"]').click
          end
          if wait_for_otp == false
            sleep 1
            browser.element(xpath: '//*[@id="member"]').click
            sleep 1
            if customer.number_of_appointments.eql?(2)
              browser.element(xpath: '//*[@id="member"]/option[1]').click
              sleep 1
            else
              browser.element(xpath: '//*[@id="member"]/option[2]').click
              sleep 1
            end
            browser.element(xpath: '//*[@id="centre"]').click
            sleep 1
            browser.element(xpath: '//*[@id="centre"]').children.select{|e| e.text.eql?(customer.centre_city)}[0].click
            sleep 1
            browser.element(xpath: '//*[@id="category"]').click
            sleep 1
            browser.element(xpath: '//*[@id="category"]').children.select{|e| e.text.eql?(customer.appointment_category)}[0].click
            sleep 1
            browser.text_field(xpath: '//*[@id="phone"]').set customer.phone_number[3..]
            sleep 1
            # byebug
            browser.element(xpath: '//*[@id="verification_code"]').click
            if browser.element(xpath: '//*[@id="slideup_div"]/div[3]/p').exists? && browser.element(xpath: '//*[@id="slideup_div"]/div[3]/p').text.eql?("Captcha verification failed.")
              browser.refresh
              wait_for_otp = false
            else
              wait_for_otp = true
              get_otp(customer)
            end
            # byebug
          end
          customer.reload
          if customer.verification_code.eql?("")
            sleep 2
          else
            browser.text_field(xpath: '//*[@id="otp"]').set customer.verification_code
            browser.element(xpath: '//*[@id="em_tr"]/div[3]/input').click
            wait_for_otp = false
            customer.update!(verification_code: "")
          end
        else
          break
        end
      end
      browser.execute_script('window.scrollBy(0, 400)')
      browser.execute_script('window.scrollBy(0, 400)')
      browser.element(xpath: '//*[@id="pakFirst"]/section/div/div/div/div[3]/div[1]/button').click
      loop do
        start_time = Time.now
        puts "start time  #{start_time}" 
        if browser.url.include?("family")
          browser.send_keys([:control, '-'])
          browser.send_keys([:control, '-'])
          browser.send_keys([:control, '-'])
          customers = Customer.where(family_id: customer.family_id)
          # byebug
          customers.each_with_index do |customer, index|
            browser.element(xpath: '//*[@id="app_date"]').click;
            select_first_available_date(browser)
            browser.element(xpath: '//*[@id="loc_tr"]/td[1]').click
            dropdown = browser.element(xpath: "//*[@id='app_time#{index+1}']")
            available_options = dropdown.options.reject { |option| option.text.empty? }
            if available_options.any?
              available_options.each { |option| puts "Available slot: #{option.text}" }  # Print available slots for verification
              dropdown.select(available_options.first.text)
              puts "Selected slot: #{available_options.first.text}"
              is_slot_done = true
            else
              puts "No available options to select."
            end
            browser.element(xpath: '//*[@id="loc_tr"]/td[1]').click
            if !retrying
              browser.element(xpath: "//*[@id='VisaTypeId-#{index+1}']").children.each do |visa_type|
                visa_type.click if visa_type.text.eql?(customer.visa_type)
              end
              browser.text_field(xpath: "//*[@id='first_name-#{index+1}']").set customer.first_name
              browser.text_field(xpath: "//*[@id='last_name-#{index+1}']").set customer.last_name

              set_date(browser, customer.birth_date.year.to_s, browser.text_field(xpath: "//*[@id='date_of_birth-#{index+1}']"), customer.birth_date)

              browser.text_field(xpath: "//*[@id='passport_number-#{index+1}']").set customer.passport_number

              set_date(browser, customer.birth_date.year.to_s, browser.text_field(xpath: "//*[@id='pptIssueDate-#{index+1}']"), customer.passport_issue_date)

              set_date(browser, customer.birth_date.year.to_s, browser.text_field(xpath: "//*[@id='pptExpiryDate-#{index+1}']"), customer.passport_expiry_date)

              browser.text_field(xpath: "//*[@id='pptIssuePalace-#{index+1}']").set customer.passport_issue_place
            end
          end
          if !retrying
            browser.element(xpath: '//*[@id="vasId12"]').click if customer.is_sms
            browser.element(xpath: '//*[@id="vasId2"]').click if customer.is_prime_time_service
            browser.element(xpath: '//*[@id="vasId6"]').click if customer.is_form_filling
            browser.element(xpath: '//*[@id="vasId3"]').click if customer.is_photocopy_b_w
            browser.element(xpath: '//*[@id="vasId5"]').click if customer.is_photograph
            browser.element(xpath: '//*[@id="vasId1"]').click if customer.is_premium_lounge
          end
            
            # browser.execute_script('window.scrollBy(0, 400)')
            # browser.execute_script('window.scrollBy(0, 400)')
            # captcha = browser.element(xpath: '//*[@id="captcha-img"]')
            # browser.screenshot.save("test.jpg")
            # puts captcha.inspect
            # image = File.open("~/Desktop/test.png", "r")
            # result = client.normal({ image: image.source })
            # # OR
            # result = client.normal({
            # image: 'https://site-with-captcha.com/path/to/captcha.jpg'
            # })
            # text = image.to_s
            # puts text

            # raise Exception.new "Browser error" if !browser.present?
            # UserMailer.with(user: e, script: "bc_racing_products").issue_in_script.deliver_now
            elapsed_time = Time.now - start_time
            puts "Elapsed time: #{elapsed_time}"
            # byebug
            if elapsed_time >= 58 && is_slot_done.eql?(false)
              browser.element(xpath: '//*[@id="change-image"]/img').click
              browser.execute_script('window.scrollBy(0, -200)')
              browser.element(xpath: '//*[@id="app_date"]').click;
              retrying = true
              elapsed_time = 0
              browser.send_keys([:control, '-'])
              next
            else
              wait_time = 59 - elapsed_time
              retrying = true
              elapsed_time = 0
              sleep wait_time
              browser.element(xpath: '//*[@id="change-image"]/img').click
              browser.execute_script('window.scrollBy(0, -200)')
              browser.element(xpath: '//*[@id="app_date"]').click;
              browser.send_keys([:control, '-'])
              next
            end
          
        else
          browser.element(xpath: '//*[@id="app_date"]').click;
          select_first_available_date(browser)
          dropdown = browser.element(xpath: '//*[@id="app_time"]')
          available_options = dropdown.options.reject { |option| option.text.empty? }
          if available_options.any?
            available_options.each { |option| puts "Available slot: #{option.text}" }  # Print available slots for verification
            dropdown.select(available_options.first.text)
            puts "Selected slot: #{available_options.first.text}"
            is_slot_done = true
          else
            puts "No available options to select."
          end
          browser.element(xpath: '/html/body/div[1]/section[1]/div/div[4]/div/table/tbody/tr[2]/td/table/tbody/tr[4]/td').click
          if !retrying
            browser.element(xpath: '//*[@id="VisaTypeId"]').children.each do |visa_type|
              visa_type.click if visa_type.text.eql?(customer.visa_type)
            end
            browser.text_field(xpath: '//*[@id="first_name"]').set customer.first_name
            browser.text_field(xpath: '//*[@id="last_name"]').set customer.last_name

            set_date(browser, customer.birth_date.year.to_s, browser.text_field(xpath: '//*[@id="dateOfBirth"]'), customer.birth_date)

            browser.text_field(xpath: '//*[@id="passport_no"]').set customer.passport_number

            set_date(browser, customer.birth_date.year.to_s, browser.text_field(xpath: '//*[@id="pptIssueDate"]'), customer.passport_issue_date)

            set_date(browser, customer.birth_date.year.to_s, browser.text_field(xpath: '//*[@id="pptExpiryDate"]'), customer.passport_expiry_date)

            browser.text_field(xpath: '//*[@id="pptIssuePalace"]').set customer.passport_issue_place
          
            browser.element(xpath: '//*[@id="vasId12"]').click if customer.is_sms
            browser.element(xpath: '//*[@id="vasId2"]').click if customer.is_prime_time_service
            browser.element(xpath: '//*[@id="vasId6"]').click if customer.is_form_filling
            browser.element(xpath: '//*[@id="vasId3"]').click if customer.is_photocopy_b_w
            browser.element(xpath: '//*[@id="vasId5"]').click if customer.is_photograph
            browser.element(xpath: '//*[@id="vasId1"]').click if customer.is_premium_lounge
          end
          
          # browser.execute_script('window.scrollBy(0, 400)')
          # browser.execute_script('window.scrollBy(0, 400)')
          # captcha = browser.element(xpath: '//*[@id="captcha-img"]')
          # browser.screenshot.save("test.jpg")
          # puts captcha.inspect
          # image = File.open("~/Desktop/test.png", "r")
          # result = client.normal({ image: image.source })
          # # OR
          # result = client.normal({
          # image: 'https://site-with-captcha.com/path/to/captcha.jpg'
          # })
          # text = image.to_s
          # puts text

          # raise Exception.new "Browser error" if !browser.present?
          # UserMailer.with(user: e, script: "bc_racing_products").issue_in_script.deliver_now
          elapsed_time = Time.now - start_time
          puts "Elapsed time: #{elapsed_time}"
          # byebug
          if elapsed_time >= 58 && is_slot_done.eql?(false)
            browser.element(xpath: '//*[@id="change-image"]/img').click
            browser.element(xpath: '//*[@id="app_date"]').click;
            retrying = true
            elapsed_time = 0
            browser.execute_script('window.scrollBy(0, -400)')
            next
          else
            wait_time = 59 - elapsed_time
            retrying = true
            elapsed_time = 0
            sleep wait_time
            browser.execute_script('window.scrollBy(0, -400)')
            browser.element(xpath: '//*[@id="change-image"]/img').click
            browser.element(xpath: '//*[@id="app_date"]').click;
            next
          end
        end
      end
    rescue Exception=> e
      puts e.message
    end
  end

  def set_date(browser, date, element, customer)
    element.click
    loop do
      if browser.element(xpath: '/html/body/div[7]').text.include?(customer.year.to_s)
        browser.element(xpath: '/html/body/div[7]/div[3]/table/tbody/tr/td').children.each do |year|
          year.click if year.text.eql?(customer.year.to_s)
        end
        browser.element(xpath: '/html/body/div[7]/div[2]/table/tbody/tr/td').children.each do |month|
          month.click if month.text.eql?(customer.strftime('%b'))
        end
        all_dates = browser.element(xpath: '/html/body/div[7]/div[1]/table/tbody').children
        new_dates = []
        all_dates.each do |dates|
          new_dates << dates.collect{|d| d}
          new_dates = new_dates.flatten
        end
        date = new_dates.select { |date| date if date.text.eql?(customer.strftime('%d').to_i.to_s) }
        date[0].click
        if browser.element(xpath: '/html/body/div[1]/section[1]/div/div[4]/div/table/tbody/tr[2]/td/table/tbody/tr[4]/td').present?
          browser.element(xpath: '/html/body/div[1]/section[1]/div/div[4]/div/table/tbody/tr[2]/td/table/tbody/tr[4]/td').click
        else
          browser.element(xpath: '//*[@id="loc_tr"]/td[1]').click
        end

        puts "date done"
        break

      elsif !browser.element(xpath: '/html/body/div[7]').text.include?(customer.year.to_s)
        if browser.element(xpath: '/html/body/div[7]/div[3]/table/thead/tr/th[1]').present? 
          browser.element(xpath: '/html/body/div[7]/div[3]/table/thead/tr/th[1]').click
        else
          browser.element(xpath: '/html/body/div[7]/div[3]/table/thead/tr/th[3]').click
        end
        next
      end
    end
  end

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
      # sleep 1
      puts slot.text
      if !slot.attributes[:title].eql?("Not Allowed") && !slot.attributes[:title].eql?("Slots Full") && !slot.attributes[:title].eql?("Off Day")
        slot.click
      end
    end
  end

  def get_otp(customer)
    # byebug
    puts "Get otp"
    customer.update!(verification_code: "")
  end
end