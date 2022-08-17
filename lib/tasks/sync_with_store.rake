require 'uri'
require 'net/http'
require 'nokogiri'
require 'open-uri'

task sync_with_store: :environment do
  store = Store.find_by(store_id: ENV['STORE_ID'])
  product_collection="collections/all/products"
  page_number = 0
  temp=0
  page_count=0
  loop do
    page_number +=1 
    temp = 0
    if store.store_id.eql?("maperformance")
      last_offset=Maperformancelog.last.present? ? Maperformancelog.last['offset'].to_i : 0
        if(last_offset == 0)
          temp += 1
          add_offset_of_maperformance(temp) 
        else
          temp = last_offset 
        end
    elsif store.store_id.eql?("throtl")
      last_offset=Throtlurllog.last.present? ? Throtlurllog.last['offset'].to_i : 0
      if(last_offset == 0)
        temp += 1
        add_offset_of_throtl(temp) 
      else
        temp = last_offset 
      end
    # else
    #   page_number += 1
    end
    # temp = 0
    begin
      if store.store_id.eql?("maperformance") || store.store_id.eql?("throtl")
        puts "=============================== #{temp} ==============================="
          products = get_request("#{store.href}.json?limit=99999&page=#{temp}")
          # add_offset_of_maperformance(temp) 
      elsif store.store_id.eql?("maxtondesignusa")
         products = get_request("#{store.href}/#{product_collection}.json?limit=99999&page=#{page_number}")
      else
          products = get_request("#{store.href}.json?limit=99999&page=#{page_number}")
      end
    rescue StandardError => e
      puts 'Exception throws getting products'
      puts e.backtrace
      sleep 60
      retry
    end
    if products['products'].empty? 
      if store.store_id.eql?("maxtondesignusa")
        product_collection="products"
        page_count +=1
        products = get_request("#{store.href}/#{product_collection}.json?limit=99999&page=#{page_count}")
      else
        puts 'no record found'
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
          logger.error e.message
          e.backtrace.each { |line| logger.error line }
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
            data = Parser.new(file, store.store_id, variant, product_brand).parse
            if !data[:price].blank?
              data[:price] = data[:price].include?(',') || data[:price].include?('$') ? '%.2f' % data[:price].tr('$ ,', '') : '%.2f' % data[:price]
            end
            add_product_in_store(store, data[:brand], data[:mpn], data[:sku], data[:stock], product_slug,variant['id'], variant['product_id'], variant_href, data[:price], data[:title])
            # temp = temp + 1
            # puts "=============================== #{temp} ==============================="
            puts "#{store}, #{data[:brand]}, #{data[:mpn]}, #{data[:sku]}, #{data[:stock]}, #{product_slug}, #{variant['id']}, #{variant['product_id']}, #{variant_href}, #{data[:price]}, #{data[:title]}"
          end  
        rescue StandardError => e
          logger.error e.message
          e.backtrace.each { |line| logger.error line }
          puts "Exception in Parsing Nokogiri::HTML #{e}"
          sleep 1
          retry if (retries += 1) < 3
        end
      rescue StandardError => e
        puts e.backtrace
        puts "Exception in finding product variant #{e}"
        puts "URI = #{variant_href}"
        next
      end
    end
    if store.store_id.eql?("maperformance")
        temp = temp + 1
        add_offset_of_maperformance(temp) 
    end
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

def add_offset_of_maperformance(offset)
  Maperformancelog.find_or_create_by(offset: offset)
end

def add_offset_of_throtl(offset)
  Throtlurllog.find_or_create_by(offset: offset)
end

def add_product_in_store(store, brand, mpn, sku, stock, slug, variant_id, product_id, href, price, title)
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
      href: href, price: price, product_title: title)
    latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, sku: sku,
      inventory_quantity: stock, slug: slug, variant_id: variant_id, product_id: product_id,
      href: href, price: price, product_title: title)
  end
  # latest = store.latest_products.find_by(variant_id: variant_id, product_id: product_id)
  # puts "After Stock: #{latest.inventory_quantity} After Date: #{latest.updated_at}"
end
