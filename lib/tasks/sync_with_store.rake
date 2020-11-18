require 'uri'
require 'net/http'
require 'nokogiri'
require 'open-uri'

task sync_with_store: :environment do
  store = Store.find_by(store_id: ENV['STORE_ID'])
  page_number = 0

  loop do
    page_number += 1
    products = begin
      get_request("#{store.href}.json?limit=99999&page=#{page_number}")
    rescue StandardError => e
      puts 'Exception throws getting products'
      sleep 60
      retry
    end
    if products['products'].empty?
      puts 'no record found'
      break
    end
    products['products'].each do |product|
      product_slug = product['handle']
      product_brand = product['vendor']

      product['variants'].each do |variant|
        variant_href = "#{store.href}/#{product_slug}?variant=#{variant['id']}"
        puts variant_href.to_s
        file = begin
          URI.open(variant_href)
        rescue OpenURI::HTTPError => e
          puts "EXception in OpenURI #{e}"
          sleep 60 * 5
          retry
        end
        retries = 0
        begin
          retries ||= 0
          data = Parser.new(file, store.store_id, variant, product_brand).parse
          add_product_in_store(store, data[:brand], data[:mpn], data[:sku], data[:stock],
                               product_slug, variant['id'], variant['product_id'], variant_href,
                               data[:price], data[:title])
          # puts "brand #{brand} mpn #{mpn} stock #{stock} sku #{variant["sku"]}}"
          puts "Price #{data[:price]} Title #{data[:title]}"
        rescue StandardError => e
          puts "EXception in Parsing Nokogiri::HTML #{e}"
          sleep 1
          retry if (retries += 1) < 3
        end
      rescue StandardError => e
        puts "EXception in finding product variant #{e}"
        next
      end
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

def add_product_in_store(store, brand, mpn, sku, stock, slug, variant_id, product_id, href, price, title)
  latest = store.latest_products.find_or_create_by(variant_id: variant_id, product_id: product_id)

  latest.update(brand: brand, mpn: mpn, sku: sku, inventory_quantity: stock, slug: slug,
    href: href, price: price, product_title: title)

  latest.archive_products.create(store_id: store.id, brand: brand, mpn: mpn, sku: sku,
    inventory_quantity: stock, slug: slug, variant_id: variant_id, product_id: product_id,
    href: href, price: price, product_title: title)
end
