require 'watir'
require 'webdrivers/chromedriver'
desc 'Scrape data from milltekcorp automation watir gem'


task milltekcorp: :environment do
    store = Store.find_by(store_id: 'milltekcorp')
    # --headless
    # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
    # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    #for live 
    Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
    Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']
    
    browser=Watir::Browser.new :chrome , args: %w[--headless --ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu]
    raise Exception.new "Browser 1 not found" if !browser.present? 

    data=nil
    retry_index=0
    sections=[]
    begin
        retry_index ||=0
        browser.goto store.href
        raise Exception.new "Browser error" if !browser.present?

    rescue StandardError => e
        puts "#{e}"
        sleep 10
        retry if (retry_index += 1) < 3
    end

        # Authenticate and Navigate to the store
    if browser.text_field(xpath: '//*[@id="frmUsername"]').present?
        browser.text_field(xpath: '//*[@id="frmUsername"]').set 'moddedeuros'
        browser.text_field(xpath: '//*[@id="frmPassword"]').set 'se!aAD#02ZTq'
        browser.button(xpath: '//*[@id="submit"]').click
        browser.link(xpath: '//*[@id="menu"]/nav/ul/li[2]/a').click
    else
        browser.url = "http://dealer.milltekcorp.com/products.cfm"
    end 
    sections = ""
    if browser.element(xpath: '//*[@id="content-main"]').present?
        count = browser.element(xpath: '//*[@id="content-main"]').children.count
        for index in 1..count do
            if browser.element(xpath: '//*[@id="content-main"]/div['+index.to_s+']').present?
                if browser.element(xpath: '//*[@id="content-main"]/div['+index.to_s+']').preceding_siblings.present?
                    if browser.element(xpath: '//*[@id="content-main"]/div['+index.to_s+']').preceding_siblings.last.preceding_siblings.last.text.eql?("Audi") ||
                        browser.element(xpath: '//*[@id="content-main"]/div['+index.to_s+']').preceding_siblings.last.preceding_siblings.last.text.eql?("BMW") ||
                        browser.element(xpath: '//*[@id="content-main"]/div['+index.to_s+']').preceding_siblings.last.preceding_siblings.last.text.eql?("Volkswagen")
                        sections << "//*[@id='content-main']/div[#{index}]||"
                        puts "Starting..............."
                    else
                        next
                    end
                end
            end
        end
        sections = sections.split("||")
    end

    puts "=================== Browser-1 start== #{browser.url} ======================"
    

    variants = {}
    model = ""
    sections.each do |section|
        count_number = 0
        browser.element(xpath: section).children[4].children.each_with_index do |element, index|
           next if element.text.eql?("")
           model = element.text if element.tag_name.eql?("h3")
           variants[model.to_s] = "" if element.tag_name.eql?("h3")
           variants[model.to_s] << "http://dealer.milltekcorp.com/#{element.a.attributes[:href]} || " if element.tag_name.eql?("div")
           link = variants[model.to_s].split("||")
        end
    end
    
    variants.keys.each do |key|
        model = key
        variants[key].split(" || ").each do |url|
            extract_data(url, browser, model)
            puts "********************************************************************************************************"
            puts "************************************   Starting Model   ************************************************"
            puts "********************************************************************************************************"
        end
    end   
end

def extract_data url, browser, model
    browser.goto url

    #################################### Kit (whole-product) data variables
    brand = ""
    kit_name = nil
    primary_stock = nil
    secondary_stock = nil
    kit_part_number = nil
    price_MAP = nil
    dealer_cost = nil


    ##################################### sub-products data variables
    us_local_stock = nil
    uk_remote_stock = nil
    product_part_number = nil
    product_description = nil
    product_price_MAP = nil
    product_dealer_cost = nil



    product = browser.element(xpath: '//*[@id="content-main"]/h1').text
    brand = product.split(" ")[0]
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    puts "******************* Brand: #{brand} *********************** "
    puts "------------------- Model: #{model} ------------------------"
    puts "*************** Link: #{url} ****************** "

    
    
    if browser.element(xpath: '//*[@id="content-main"]').present?
        browser.elements(xpath: '//*[@class="product-container"]').each do |item|
            kit_name = item.children[1].children.first.children.first.children[1].text.split("\n")[0]
            
            #############################################################################
            if item.children[1].children.first.children.first.children[2].text.eql?("NOT IN STOCK\nPrimary Stock")
                primary_stock = 0 
            else
                primary_stock = (item.children[1].children.first.children.first.children[2].text.gsub(/[^0-9]/, '')).to_i
            end
            
            if item.children[1].children.first.children.first.children[3].text.eql?("NOT IN STOCK\nSecondary Stock")
                secondary_stock = 0 
            else
                secondary_stock = (item.children[1].children.first.children.first.children[3].text.gsub(/[^0-9]/, '')).to_i
            end
            #############################################################################
            

            data = item.children.last.table.tbody.children.last.td.table.tbody.children
            data.each do |row|
                if row.text.split(": ")[0].eql?("System number")
                    kit_part_number = row.text.split(" ")[2] 
                end
                if row.text.split(": ")[0].eql?("Pipe diameter")
                    price_MAP = row.text.split(" ").last      
                end
                if row.text.split(": ")[0].eql?("DEALER COST")
                    dealer_cost =  row.text.split(" ").last
                end
            end

                puts "***************************************************************************************"
                puts "*****************************  Kit Record  ***************************************"
                puts "--------------- Product Name: #{kit_name} --------------------"
                puts "--------------- primary_stock: #{primary_stock} --------------------"
                puts "--------------- secondary_stock: #{secondary_stock} --------------------"
                puts "--------------- kit_part_number: #{kit_part_number} --------------------"
                puts "--------------- price_MAP: #{price_MAP} --------------------"
                puts "--------------- dealer_cost: #{dealer_cost} --------------------"
                
                kit_id = add_kit_data(kit_name, primary_stock, secondary_stock, kit_part_number, price_MAP, dealer_cost, url, brand, model)

                index = 1
                count = item.children[2].table.tbody.children.count - 1
                while index < count    
                    kit_details = item.children[2].table.tbody.children[index] 
                
                    us_local_stock = (kit_details.children[0].text).to_i
                    uk_remote_stock = (kit_details.children[1].text).to_i
                    product_part_number = kit_details.children[2].text
                    product_description = kit_details.children[3].text
                    product_price_MAP = kit_details.children[4].text
                    product_dealer_cost = kit_details.children[6].text
                    
                    index +=1
                    
                    puts "#####################  Product / Variant / sub-product Record  ##########################"
                    puts "---------us_local_stock:  #{us_local_stock} -------------"
                    puts "---------uk_remote_stock: #{uk_remote_stock} -------------"
                    puts "---------product_part_number: #{product_part_number} -------------"
                    puts "---------product_description: #{product_description} -------------"
                    puts "---------product_price_MAP: #{product_price_MAP} -------------"
                    puts "---------product_dealer_cost: #{product_dealer_cost} -------------"

                    add_kit_products_data(kit_id, us_local_stock, uk_remote_stock, product_part_number, product_description, product_price_MAP, product_dealer_cost)

                    us_local_stock = nil
                    uk_remote_stock = nil
                    product_part_number = nil
                    product_description = nil
                    product_price_MAP = nil
                    product_dealer_cost = nil
                end


                kit_part_number = nil
                primary_stock = nil
                secondary_stock = nil
                part_number = nil
                price_MAP = nil
                dealer_cost = nil
               
                puts "************************************************************************************************"
                puts "*****************************  Kit Record Finished  ***************************************"
                
                
        end
    end
end


def add_kit_data kit_name, primary_stock, secondary_stock, kit_part_number, price_MAP, dealer_cost, url, brand, model
    kit = MilltekcorpKit.find_or_create_by(kit_part_number: kit_part_number)    
    kit.update(kit_name: kit_name, primary_stock: primary_stock, secondary_stock: secondary_stock, kit_part_number: kit_part_number, price_MAP: price_MAP, dealer_cost: dealer_cost, href: url, brand: brand, model: model)
    
    kit.id
end


def add_kit_products_data kit_id, us_local_stock, uk_remote_stock, product_part_number, product_description, product_price_MAP, product_dealer_cost
    MilltekcorpProduct.find_or_create_by(product_part_number: product_part_number).update(milltekcorp_kit_id: kit_id, us_local_stock: us_local_stock, uk_remote_stock: uk_remote_stock, product_part_number: product_part_number, product_description: product_description, product_price_MAP: product_price_MAP, product_dealer_cost: product_dealer_cost)
end