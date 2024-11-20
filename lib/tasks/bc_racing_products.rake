require 'selenium-webdriver'
require 'watir'
require 'webdrivers/chromedriver'
require 'rtesseract'
require 'api_2captcha'
require 'fileutils'
require 'base64'

desc 'To scrape bc racing products using automation watir gem'
task get_snaps: :environment do
  puts "I'm in"

  Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"

  client = Api2Captcha.new("6fc6e7e9ff29bacf040d24bc65f5c9ee")

  begin
    browser = Watir::Browser.new :chrome, args: %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized]

    # Navigate to Page
    browser.goto "https://mypastest.pastest.com/dashboard/168?subscriptionId=1400775"

    browser.text_field(xpath: '//*[@id="MemberAuthenticationDetails_Username"]').set 'dr.muneebahmad.88@gmail.com'
    browser.text_field(xpath: '//*[@id="MemberAuthenticationDetails_Password"]').set 'lk5674mustpassmrcp'

    browser.element(xpath: '//*[@id="login"]').click
    puts "login done"
    
    sleep 10
    
    
    
    # Create directory if it doesn't exist
    sleep 5
    directory = JSON.parse(browser.element(xpath: '//*[@id="SvWPerformance"]').attributes.values[3])["labels"][0]
    FileUtils.mkdir_p(directory)
    puts "Directory created: #{directory}"
    sleep 2
    browser.element(xpath: '//*[@id="btnReviewAnswers"]').click
    sleep 2
    qs = browser.element(xpath: '//*[@id="pageTitle"]').text.split(" ")[3].to_i
    for loop in 1..qs
      sleep 4
      browser.execute_script('window.scrollBy(0, 1500)')
      puts "Scrolling done"
      sleep 1
      browser.element(xpath: '//*[@id="frmQBank"]/div[6]/input[2]').click
      puts "Tag questions clicked"
      sleep 1
      browser.execute_script("window.print()")
      sleep 2
      downloaded_file = "/home/ads/Projects/modded-systems/#{directory}/MyPastest.pdf"
      Watir::Wait.until { File.exist?(downloaded_file) }

      question_pdf_path = File.join(directory, "Q#{loop}.pdf")
      File.rename(downloaded_file, question_pdf_path)
      puts "Saved PDF to #{question_pdf_path}"
      # byebug

      browser.element(xpath: '//*[@id="btnNextQuestion"]').click
    end
    # puts "Print setting"
    # pdf_path = File.join(directory, 'Question_1.pdf')

    # # Trigger the print to PDF process
    # browser.execute_script("window.print()")

    # # Wait for the PDF to be saved (this can take a few seconds depending on the page)
    # sleep 5  # Adjust this time depending on the page load speed

    # # Move the generated PDF file to your desired location
    # FileUtils.mv('/path/to/downloaded/pdf', pdf_path)

    # puts "PDF saved to #{pdf_path}"
  ensure
    browser.close
  end
end