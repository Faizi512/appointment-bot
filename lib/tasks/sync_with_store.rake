require 'uri'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'watir'
require 'webdrivers/chromedriver'
require 'openssl'
require 'selenium-webdriver'

task sync_with_store: :environment do

  store = Store.find_by(store_id: ENV['STORE_ID'])
  # browser = get_browser store if store.store_id.eql?("silver_suspension")

  product_collection="collections/all/products"
  page_number = 0
  temp=0
  page_count=0
  
  loop do
    page_number +=1 
    if store.store_id.eql?("maperformance")
      last_offset=Maperformancelog.last.present? ? Maperformancelog.last['offset'].to_i : 0
        if(last_offset == 0)
          temp += 1
          add_offset_of_maperformance(temp) 
        else
          temp = last_offset
        end
    elsif store.store_id.eql?("throtl")
      last_offset=LoggingTable.where(store_id: store.id).last.present? ? (LoggingTable.where(store_id: store.id).last.last_page.eql?(false) ? LoggingTable.where(store_id: store.id).last['page_number'].to_i : LoggingTable.where(store_id: store.id).destroy_all && 0) : 0
      if(last_offset == 0)
        temp += 1
      else
        temp = last_offset + 1
      end
    end
    begin
      if store.store_id.eql?("maperformance") || store.store_id.eql?("throtl")
        puts "=============================== #{temp} ==============================="
          products = get_request("#{store.href}.json?limit=99999&page=#{temp}")
          # add_offset_of_maperformance(temp) 
      elsif store.store_id.eql?("maxtondesignusa")
         products = get_request("#{store.href}/#{product_collection}.json?limit=99999&page=#{page_number}")
      elsif store.store_id.eql?("silver_suspension")
        # pp = Curb.open_uri("#{store.href}.json?limit=99999&page=#{page_number}")
        products = get_request("#{store.href}.json?limit=99999&page=#{page_number}")
      else
        products = get_request("#{store.href}.json?limit=99999&page=#{page_number}")
      end
    rescue StandardError => e
      puts 'Exception throws getting products'
      # logger.error e.message
      # e.backtrace.each { |line| logger.error line }
      sleep 60
      retry
    end
    if products['products'].empty? 
      if store.store_id.eql?("maxtondesignusa")
        product_collection="products"
        page_count +=1
        products = get_request("#{store.href}/#{product_collection}.json?limit=99999&page=#{page_count}")
      elsif store.store_id.eql?("maperformance")
        puts '{(=============================================================================================)}'
        puts 'no record found'
        puts '{(=============================================================================================)}'
        msg = "Script successfully completed"
        UserMailer.with(user: msg, script: "#{store.name}").completion_alert.deliver_now
        temp=0
        add_offset_of_maperformance(temp)
      else
        puts '{(=============================================================================================)}'
        puts 'no record found'
        puts '{(=============================================================================================)}'
        msg = "Script successfully completed"
        UserMailer.with(user: msg, script: "#{store.name}").completion_alert.deliver_now
        LoggingTable.create!(store_id: store.id, url: "#{store.href}.json?limit=99999&page=#{temp}", page_number: temp, last_page: true)
        break
      end
    end
    products['products'].each do |product|
      product_slug = product['handle']
      product_brand = product['vendor']
      product['variants'].each do |variant|
       if store.store_id.eql?("maxtondesignusa")
        variant_href = "#{store.href}/#{product_collection}/#{product_slug}?variant=#{variant['id']}"
       else
        variant_href = "#{store.href}/#{product_slug}?variant=#{variant['id']}"
       end
        # variant_href="https://maxtondesignusa.net/collections/all/products/front-splitter-flaps-volkswagen-golf-7-r-r-line-facelift?variant=42427985527007"
        retry_uri = 0
        file = begin
          retry_uri ||= 0
          URI.open(variant_href)
        rescue OpenURI::HTTPError => e
          puts "Exception in method OpenURI #{e} for #{store.name} URL:#{variant_href}" if retry_uri.positive?
          removed_product = store.latest_products.find_by(variant_id: variant['id'], product_id: variant['product_id']) if retry_uri.positive?
          removed_product.delete if removed_product.present?
          sleep 1
          retry if (retry_uri += 1) < 2
        end

        retries = 0
        begin
          retries ||= 0
          if(store.store_id=="NeuspeedRSWheels")
            hash_data = Parser.new(file, store.store_id, variant, product_brand).parse
            hash_data.each do |data|
              data[:price] = data[:price].to_s.include?('$') ? '%.2f' % data[:price].to_s.tr('$ ,', '') : '%.2f' % data[:price].to_s
              add_product_in_store(store, data[:brand], data[:mpn], data[:sku], data[:stock], product_slug,variant['id'], variant['product_id'], variant_href, data[:price], data[:title])
              puts "#{store}, #{data[:brand]}, #{data[:mpn]}, #{data[:sku]}, #{data[:stock]}, #{product_slug}, #{variant['id']}, #{variant['product_id']}, #{variant_href}, #{data[:price]}, #{data[:title]}"
            end
          else
            puts variant_href
            variant = variant.merge({"variant_href"=>variant_href}) if (store.store_id=="silver_suspension")
            data = Parser.new(file, store.store_id, variant, product_brand).parse
            if !data[:price].blank?
              data[:price] = data[:price].include?(',') || data[:price].include?('$') ? '%.2f' % data[:price].tr('$ ,', '') : '%.2f' % data[:price]
            end
            add_product_in_store(store, data[:brand], data[:mpn], data[:sku], data[:stock], product_slug, variant['id'], variant['product_id'], variant_href, data[:price], data[:title], data[:description])
            if(store.store_id=="maperformance")
              add_product_in_product_details(store, variant['id'], data[:description], data[:features], data[:benefits], data[:included], variant_href)
            end
            # temp = temp + 1
            puts "-> Store: #{store}, -> Brand: #{data[:brand]}, -> mpn: #{data[:mpn]}, -> sku: #{data[:sku]}, -> stock: #{data[:stock]}, -> product_slug: #{product_slug}, #{variant['id']}, #{variant['product_id']}, #{variant_href}, -> price: #{data[:price]}, -> title: #{data[:title]}, -> description: #{data[:description]}"
            puts "====================================================================================================="
          end  
        rescue StandardError => e
          puts "Exception in Parsing Nokogiri::HTML #{e}"
          sleep 1
          retry if (retries += 1) < 3
        end
      rescue StandardError => e
        puts "Exception in finding product variant #{e}"
        puts "URI = #{variant_href}"
        next
      end
    end
    if store.store_id.eql?("maperformance")
        temp = temp + 1
        add_offset_of_maperformance(temp) 
    end
    puts "#{store.href}/#{product_collection}.json?limit=99999&page=#{temp}"
    LoggingTable.create!(store_id: store.id, url: "#{store.href}.json?limit=99999&page=#{temp}", page_number: temp, last_page: false)
    puts "====================== Page end =================================="
  end
end
def get_request(urll)
  url = URI(urll)
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)
  response = https.request(request)
  JSON.parse response.read_body
end

def add_offset_of_maperformance(temp)
  Maperformancelog.find_or_create_by(offset: temp)
end

def add_product_in_store(store, brand, mpn, sku, stock, slug, variant_id, product_id, href, price, title, description)
  if(store.store_id.eql?("Neuspeed RSWheels"))
    latest = store.latest_products.find_or_create_by(variant_id: variant_id, product_id: product_id, mpn: mpn)
  else
    latest = store.latest_products.find_or_create_by(variant_id: variant_id, product_id: product_id)
  end
    # puts "Before Stock: #{latest.inventory_quantity} Before Date: #{latest.updated_at}"
  if(store.name.eql?("Maxton Design USA"))
    latest.update(brand: brand, mpn: sku, sku: mpn, inventory_quantity: stock, slug: slug,
      href: href, price: price, product_title: title)
    latest.archive_products.create(store_id: store.id, brand: brand, mpn: sku, sku: mpn,
      inventory_quantity: stock, slug: slug, variant_id: variant_id, product_id: product_id,
      href: href, price: price, product_title: title)
  else
    latest.update(brand: brand, mpn: mpn, sku: sku, inventory_quantity: stock, slug: slug,
      href: href, price: price, product_title: title, description: description)
    latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, sku: sku,
      inventory_quantity: stock, slug: slug, variant_id: variant_id, product_id: product_id,
      href: href, price: price, product_title: title, description: description)
  end
  # latest = store.latest_products.find_by(variant_id: variant_id, product_id: product_id)
  # puts "After Stock: #{latest.inventory_quantity} After Date: #{latest.updated_at}"
end

def add_product_in_product_details(store, variant_id, description, features, benefits, included, variant_href)
  puts "-> variant_id: #{variant_id}"
  puts "-> description: #{description}"
  puts "-> features: #{features}"
  puts "-> benefits: #{benefits}"
  puts "-> included: #{included}"
  puts "-> variant_href: #{variant_href}"

  detail = MaPerformanceDetail.find_or_create_by(variant_id: variant_id)
  detail.update(description: description, features: features, benefits: benefits, included: included, variant_href: variant_href)
  
  puts "      ..............................................................        "
end                                                                                                                                                                               