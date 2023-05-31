require 'nokogiri'
require 'watir'
require 'webdrivers/chromedriver'
require 'selenium-webdriver'
require 'faker'
class Parser
  attr_reader :file, :store
  @index = 1
  def initialize(file, store, variant, brand)
    @file = file
    @store = store
    @variant = variant
    @brand = brand
    @sku = variant['sku']
    @price = ''
    @title = ''
    @description = ""
    @features = ""
    @benefits = ""
    @included = ""
    @map_price = ""
  end

  def parse
    doc = Nokogiri::HTML(file)
    case store
    when 'urotuning'
      urotuning_data_points(doc)
    when 'performancebyie'
      performancebyie_data_points(doc)
    when 'bmptuning'
      bmptuning_data_points(doc)
    when 'maxtondesignusa'
      maxtondesignusa_data_points(doc)
    when 'NeuspeedRSWheels'
      neuspeedRSWheels_data_points(doc)
    when 'MMRPerformance'
      mmrperformance_data_points(doc)
    when 'throtl'
      throtl_data_points(doc)
    when 'maperformance'
      maperformance_data_points(doc)
    when 'spaturbousa'
      spa_turbo_usa(doc)
    when 'fastmods'
      fastmods_data_points(doc)
    when 'silver_suspension'
      silver_suspension_data_points
    end
  end

  def fastmods_data_points doc
    @title = doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/h1").children[2].text.strip rescue nil
    salePrice = doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/div[2]/span[2]").children.text.strip() rescue  nil
    regularPrice=doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/div[2]/span[1]").children.text.strip() rescue  nil
    @price=salePrice.present? ? salePrice : regularPrice
    @brand=doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/div[3]/div[1]/div[1]/span/a").children.last.text rescue nil
    stock=doc.xpath("/html/body/div[2]/main/div[1]/div[2]/div/div[1]/div[1]/div/div[2]/div[3]/div[1]/div[6]/span/span[2]").text rescue nil
    @stock=stock.eql?("Many in stock") ? 1 : 0
    data_points_hash
  end
   
  def spa_turbo_usa(doc)
    title=doc.xpath("/html/head/meta[7]") rescue nil
    @title=title[0].present? ? title[0].attributes["content"].value : nil
    @price=doc.xpath("/html/body/div[4]/div[2]/div[2]/div/div/div/div[2]/div/div[1]/div/div/div/div[2]/div/div/div/div[1]/div[1]/form/div[2]/div[1]/div/span").children.text rescue nil
    mpn=doc.xpath("/html/body/div[4]/div[2]/div[2]/div/div/div/div[2]/meta[3]") rescue nil
    @mpn=mpn[0].present? ? mpn[0].attributes["content"].value : nil
    stock=doc.xpath("/html/body/div[4]/div[2]/div[2]/div/div/div/div[2]/div/div[1]/div/div/div/div[2]/div/div/div/div[1]/div[1]/form/div[2]/div[2]/span").text rescue nil
    @stock= stock.present? ? 1 : 0
    @brand = doc.xpath("/html/body/div[4]/div[2]/div[2]/div/div/div/div[2]/span[3]").children.text rescue ni
    data_points_hash
  end

  def urotuning_data_points doc
    @title = doc.xpath("//h2[@itemprop='name']").children.text
    price = doc.xpath("//span[@class='bold_option_price_display price']").children.last
    @price = price.text.strip if price.present?
    @brand = doc.xpath('.//meta[@itemprop=$value]', nil, { value: 'brand' }).first.attributes['content'].value rescue nil
    @mpn = doc.xpath('.//meta[@itemprop=$value]', nil, { value: 'mpn' }).first.attributes['content'].value rescue nil
    @stock = JSON.parse(doc.xpath('.//script[@data-app=$value]', nil, { value: 'esc-out-of-stock' }).first.children.first).first['inventory_quantity'] rescue nil
    data_points_hash
  end 
  def performancebyie_data_points doc
    @title = doc.xpath("//h1[@itemprop='name']").children.text
    price = doc.xpath("//span[@class='product__price']").children.last
    @price = price.text.strip if price.present?
    txt = doc.xpath("//script[contains(text(), 'inventory_quantity')]").text
    @stock = txt.split("\"id\":#{@variant['id']}")[2].split('inventory_quantity: ', 2).last.split('product_id:')[0].split(',')[0] rescue nil
    @mpn = doc.xpath("//*[contains(concat(' ', normalize-space(@class), ' '), 'product-single__sku')]").text.strip
    data_points_hash
  end

  def bmptuning_data_points doc
    @title = doc.xpath("//h1[@class='product-meta__title heading h1']").children.text
    price = doc.xpath("//span[@class='price']").children.last
    @price = price.text if price.present?
    txt = doc.xpath("//script[contains(text(), 'inventory_quantity')]").text
    @stock = txt.split("\"id\":#{@variant['id']}", 2).last.split('inventory_quantity', 2).last.split(',')[0].split(':')[1].to_i rescue nil
    @mpn = @variant['product_id']
    data_points_hash
  end

  def neuspeedRSWheels_data_points(doc)
    hash_data=[]
    @title=doc.xpath("//h1[@class='product-title']").children.text.strip
    data=doc.xpath("//select/option[@data-variant-id]")
      data.each do |products|
        stock_data = products.attributes["data-variant-quantity"].value.to_i
        @stock = stock_data > 0 ? stock_data : 0
        @price = products.children[0].text.strip.split.last.to_f
        @mpn=products.attributes["data-sku"].value
        hash_data.push(data_points_hash)
      end
    hash_data
  end

  def mmrPerformance_data_points(doc)
    @title=doc.xpath('/html/body/main/div[2]/div/div/div/div/div/div/div/div[2]/div[1]/div[2]/h1').children.text.strip
    @price=doc.xpath('/html/body/main/div[2]/div/div/div/div/div/div/div/div[2]/div[1]/div[5]/div/span/span').children.text.split("£")[1].to_f
    @mpn=doc.xpath('/html/body/main/div[2]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[1]/p/span').children.text
    @stock=doc.xpath('/html/body/main/div[2]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[2]/p/span').children.text.scan(/\d+/).first.to_i
    data_points_hash
  end

  def maxtondesignusa_data_points doc
    title = doc.xpath("/html/body/div[1]/div/main/div[1]/div/div/div/div[1]/div[1]/div/h1").text.strip() rescue nil 
    variant_title= @variant["title"].present? ? @variant["title"] : nil 
    @title = "#{title} #{variant_title}" rescue nil
    price = doc.xpath("/html/body/div[1]/div/main/div[1]/div/div/div/div[1]/div[1]/div/span[2]").price.strip() rescue nil
    @price = price if price.present?
    stock=doc.xpath("//div[@class='product__inventory hide']").text.strip.split(' ')[1].to_i rescue nil
    @stock = stock < 0 ? 0 : stock
    @mpn = @variant['product_id']
    data_points_hash
  end

  def mmrperformance_data_points(doc)
    @title = doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[2]/h1').text
    @price = doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[5]/div/span').text.present? ? doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[5]/div/span').text.split("£")[1]: ""
    txt = doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[2]/p').text
    @stock = !txt.scan(/\d/).empty? ? doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[2]/p').text.split("(")[1].split(" ")[0] : "0"
    @mpn = doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[1]/p').text.present? ? doc.xpath('//*[@id="shopify-section-product"]/div/div/div/div/div/div/div/div[2]/div[1]/div[4]/div[1]/p').text.split(":")[1] : ""
    data_points_hash
  end

  def silver_suspension_data_points
    # for local browser
    # Selenium::WebDriver::Chrome.path = "#{Rails.root}#{ENV['GOOGLE_CHROME_PATH']}"
    # Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}#{ENV['GOOGLE_CHROME_DRIVER_PATH']}"
    # chrome_options = {
    #   'goog:chromeOptions' => {
    #     'args' => %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu]
    #   }
    # }
    # browser = Watir::Browser.new :chrome, options: chrome_options
    # browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu ]
    # for live browser
     Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_PATH'] 
     Selenium::WebDriver::Chrome.driver_path = ENV['GOOGLE_CHROME_DRIVER_PATH']

    user_agent = Faker::Internet.user_agent
    browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu, --user-agent="#{user_agent}" ]
    arr = ["https://www.google.com", "https://www.instagram.com/", "https://www.facebook.com/", "https://www.udemy.com/", "https://www.coursera.org/"]
    browser.goto arr[rand(5)]
    puts browser.url
    browser.execute_script("window.scrollBy(0, 400);")
    browser.goto arr[rand(5)]
    puts browser.url
    sleep(5)
    browser.execute_script("window.scrollBy(0, 400);")
    sleep(15)
    browser.goto @variant["variant_href"]
    puts browser.url
    sleep(13)
    browser.text_field(xpath: '//*[@id="CustomerEmail"]').set 'orders@moddedeuros.com'
    sleep(2)
    browser.text_field(xpath: '//*[@id="CustomerPassword"]').set 'f0B1$I!J56&m'
    sleep(8)
    browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    browser.execute_script("$('#customer_login')[0].onsubmit()") if browser.button(xpath: '//*[@id="customer_login"]/p/button').present?
    sleep(3)
    browser.button(xpath: '//*[@id="customer_login"]/p/button').click if browser.button(xpath: '//*[@id="customer_login"]/p/button').present?
    sleep(3)

    if browser.url.eql?("https://nahmindustries.com/challenge")
      browser.close
      puts "------------- browser close (challenge) -----------------"
      sleep(300)
      silver_suspension_data_points
    end
    # browser.goto @variant["variant_href"]
    @stock = browser.element(css: 'div.grid__item.medium-up--three-fifths > div > div:nth-child(4) > div:nth-child(9) > p > b').text
    @title = browser.element(css: 'div.grid__item.medium-up--three-fifths > div > h1').text
    @map_price = browser.element(css: 'div.grid__item.medium-up--three-fifths > div > div:nth-child(4)').children[5].text.split(" ")[1]
    @price = browser.element(css: 'div.grid__item.medium-up--three-fifths > div > div:nth-child(4)').children[6].text.split(" ")[2]
    @mpn = browser.element(css: 'div.grid__item.medium-up--three-fifths > div').children[2].text    
    browser.close
    data_points_hash
  end

  def throtl_data_points doc
    @title = doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[1]/h1").present? ? doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[1]/h1").text.strip : nil
    if (@title.eql?("") || @title.eql?(nil))
      @title = doc.xpath('//*[@id="shopify-section-template--14958388772912__front"]/section/div[1]/h1').present? ? doc.xpath('//*[@id="shopify-section-template--14958388772912__front"]/section/div[1]/h1').text.strip : nil
    end
    
    price = doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[3]/div/dl/div[1]/dd/span").children.present? ? doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[3]/div/dl/div[1]/dd/span").children.text.strip : nil
    if (price.eql?("") || price.eql?(nil))
      price = doc.xpath('//*[@id="price-template--14958388772912__front"]/p').present? ? doc.xpath('//*[@id="price-template--14958388772912__front"]/p').text.strip : nil
    end
    if price.present?  
      @price = price.split(' ').count >1 ? price.split(' ')[0] : price
    else
      @price = price
    end

    stock = doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[2]/div[2]/div/div").children[1].children.text rescue nil
    @stock = stock.present? ?  stock.gsub(/[^0-9]/, '').to_i : 0
 
    if doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[2]/div[1]/p").present?
      @mpn = doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[2]/div[1]/p").children.last.present? ? doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[2]/div[1]/p").children.last.text : nil
    end

    brand = doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[1]/div[1]/a").present? ? doc.xpath("/html/body/main/section[1]/section/div/div[1]/div[2]/div[1]/div[2]/div[1]/div[1]/a") : nil
    @brand = brand.children.present? ? brand.last.text : brand.text 
    if (@brand.eql?("") || @brand.eql?(nil))
      @brand = doc.xpath('//*[@id="shopify-section-template--14958388772912__front"]/section/div[2]/div/div[2]/div[1]/div[1]/div/div[1]/a').present? ? doc.xpath('//*[@id="shopify-section-template--14958388772912__front"]/section/div[2]/div/div[2]/div[1]/div[1]/div/div[1]/a').text.strip : nil
    end
    

    if doc.xpath('//*[@id="product-description"]/div/div').children[1].present? && doc.xpath('//*[@id="product-description"]/div/div').children[1].name.eql?("ul")
      x=4
      count = doc.xpath('//*[@id="product-description"]/div/div').children.count
      while true
        if x.eql?(count)
          break
        end
        doc.xpath('//*[@id="product-description"]/div/div').children[x].text.eql?("Front Fitment Wheel Specifications table") ? break : @description = @description + "\n" + doc.xpath('//*[@id="product-description"]/div/div').children[x].text.strip
        x = x+1   
      end
      if @description.eql?("") || @description.eql?(nil)
        i = 4
        count = doc.xpath('//*[@id="product-description"]/div/div').children.count
        while true
          if i.eql?(count)
            break
          end
          (doc.xpath('//*[@id="product-description"]/div/div').children[i].name.eql?("div") || doc.xpath('//*[@id="product-description"]/div/div').children[i].text.eql?("Additional Details")) ? break : @description = @description + "\n" + doc.xpath('//*[@id="product-description"]/div/div').children[i].text.strip
          i = i+1
        end
      end    
    elsif doc.xpath('//*[@id="product-description"]/div/div').children[7].present? && doc.xpath('//*[@id="product-description"]/div/div').children[7].name.eql?("ul")
       i = 10
       count = doc.xpath('//*[@id="product-description"]/div/div').children.count
      while true
        if i.eql?(count)
          break
        end
        (doc.xpath('//*[@id="product-description"]/div/div').children[i].name.eql?("div") || doc.xpath('//*[@id="product-description"]/div/div').children[i].text.eql?("Additional Details")) ? break : @description = @description + "\n" + doc.xpath('//*[@id="product-description"]/div/div').children[i].text.strip
        i = i+1
      end
    else
      @description = nil
    end

    data_points_hash
  end

  def maperformance_data_points(doc)
    @brand = doc.xpath('//*[@id="product-template--14717802381382__main"]/div[2]/span/a/p').present? ? doc.xpath('//*[@id="product-template--14717802381382__main"]/div[2]/span/a/p').text : nil
    @title = doc.xpath('//*[@id="product-template--14717802381382__main"]/div[2]/h1').present? ? doc.xpath('//*[@id="product-template--14717802381382__main"]/div[2]/h1').text : nil
    @mpn = doc.xpath('//*[@id="myInput"]').present? ? doc.xpath('//*[@id="myInput"]').text.strip : nil
    @price = doc.xpath('//*[@id="display-1"]').present? ? doc.xpath('//*[@id="display-1"]').text.strip : nil
    
    if doc.xpath('//*[@id="dc-wrapper"]/product-variants/span[2]').present?
      raw_data = doc.xpath('//*[@id="dc-wrapper"]/product-variants/span[2]').attr("data-inventory").present? ? doc.xpath('//*[@id="dc-wrapper"]/product-variants/span[2]').attr("data-inventory").text : nil
      if !raw_data.eql?(nil)
      data = JSON.parse(raw_data)
      @stock = data[0]["quantity"].present? ? data[0]["quantity"] : 0 
      end     
    end

    # raw_data = doc.xpath("//script[@class='product-json']").text
    # if !raw_data.blank?
    #   data = JSON[raw_data]
    #   @stock = data['variants'].present? ? data['variants'][0]["inventory_quantity"] : 0
    # else
    #   @stock = 0
    # end


      if doc.xpath("//div[@class='rte desktop-full tablet-no-show zxc']").present?
        if doc.xpath("//div[@class='rte desktop-full tablet-no-show zxc']").children[0].attributes["id"].present?
          if doc.xpath("//div[@class='rte desktop-full tablet-no-show zxc']").children[0].attributes["id"].value.eql?("newdescr") 
            if doc.xpath("//div[@id='newdescr']")[0].text.present?
              if doc.xpath("//div[@id='newdescr']")[0].text.split("Features").present?
                @description = doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[0].strip : nil
              elsif doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits").present?
                @description = doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[0].strip : nil
              elsif doc.xpath("//div[@id='newdescr']")[0].children.present?
                @description = doc.xpath("//div[@id='newdescr']")[0].children[1].text.present? ? doc.xpath("//div[@id='newdescr']")[0].children[1].text.strip : nil
              end

              if doc.xpath("//div[@id='newdescr']")[0].text.split("Features").present?
                if doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Benefits").present?
                  @features = doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Benefits")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Feature")[1].split("Benefits")[0].strip : nil
                elsif doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Applications").present?
                  @features = doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Applications")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Applications")[0].strip : nil
                elsif doc.xpath("//div[@id='newdescr']")[0].children.present?
                  @features = doc.xpath("//div[@id='newdescr']")[0].children[1].text.present? ? doc.xpath("//div[@id='newdescr']")[0].children[1].text.strip : nil 
                end
              end

              if doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits").present?
                if doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].split("Applications").present?
                  @benefits = doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].split("Applications")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].split("Applications")[0].strip : nil
                elsif doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].present?
                  @benefits = doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].strip : nil
                elsif doc.xpath("//div[@id='newdescr']")[0].children.present?
                  @benefits = doc.xpath("//div[@id='newdescr']")[0].children[1].text.present? ? doc.xpath("//div[@id='newdescr']")[0].children[1].text.strip : nil 
                end
              end

              if doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?").present?
                if doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?").split("Warranty").present?
                  @included = doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?")[1].split("Warranty")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?")[1].split("Warranty")[0].strip : nil
                elsif doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?").present?
                  @included = doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?")[1].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?")[1].strip : nil
                end
              end
            puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
            end
          end
        end
      elsif doc.xpath("//div[@id='newdescr']").present?
        if doc.xpath("//div[@id='newdescr']")[0].text.present?
          if doc.xpath("//div[@id='newdescr']")[0].text.split("Features").present?
            @description = doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[0].strip : nil
          elsif doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits").present?
            @description = doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[0].strip : nil
          elsif doc.xpath("//div[@id='newdescr']")[0].children.present?
            @description = doc.xpath("//div[@id='newdescr']")[0].children[1].text.present? ? doc.xpath("//div[@id='newdescr']")[0].children[1].text.strip : nil
          end

          if doc.xpath("//div[@id='newdescr']")[0].text.split("Features").present?
            if doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Benefits").present?
              @features = doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Benefits")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Feature")[1].split("Benefits")[0].strip : nil
            elsif doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Applications").present?
              @features = doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Applications")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Features")[1].split("Applications")[0].strip : nil
            elsif doc.xpath("//div[@id='newdescr']")[0].children.present?
              @features = doc.xpath("//div[@id='newdescr']")[0].children[1].text.present? ? doc.xpath("//div[@id='newdescr']")[0].children[1].text.strip : nil 
            end
          end

          if doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits").present?
            if doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].split("Applications").present?
              @benefits = doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].split("Applications")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].split("Applications")[0].strip : nil
            elsif doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].present?
              @benefits = doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("Benefits")[1].strip : nil
            elsif doc.xpath("//div[@id='newdescr']")[0].children.present?
              @benefits = doc.xpath("//div[@id='newdescr']")[0].children[1].text.present? ? doc.xpath("//div[@id='newdescr']")[0].children[1].text.strip : nil 
            end
          end

          if doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?").present?
            if doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?").split("Warranty").present?
              @included = doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?")[1].split("Warranty")[0].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?")[1].split("Warranty")[0].strip : nil
            elsif doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?").present?
              @included = doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?")[1].present? ? doc.xpath("//div[@id='newdescr']")[0].text.split("What's In The Box?")[1].strip : nil
            end
          end
        puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
        end
      end

    data_points_hash
  end

  def data_points_hash
    {
      stock: @stock, mpn: @mpn, brand: @brand,
      sku: @sku, price: @price, title: @title,
      description: @description, features: @features,
      benefits: @benefits, included: @included,
      map_price: @map_price
    }
  end
end
