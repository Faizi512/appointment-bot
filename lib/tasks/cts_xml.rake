require 'nokogiri'
desc 'Scrape data from milltekcorp automation watir gem'


task cts_xml: :environment do
    arr = []
    store = Store.find_by(store_id: 'cts_xml')
    file = Curb.open_uri(store.href)
    doc = Nokogiri::XML(file)
    doc.xpath('//post').each_with_index do |element, index|
        sku = element.children[1].text
        title =  element.children[3].text
        price = element.children[7].text
        stock = element.children[11].text.eql?('instock') ? 10 : 0
        puts "error at index: #{index}" if sku == "" || title == ""

        puts "Product count: #{index + 1} => SKU: #{sku}, Title: #{title}, Price: #{price}, Qty: #{stock}"
        arr << sku
        puts arr.length
        puts arr.uniq.length        
        add_product sku, title, price, stock, store
    end
end

def add_product sku, title, price, stock, store
    latest = store.latest_products.find_or_create_by(mpn: sku)
    latest.update(product_title: title, mpn: sku, inventory_quantity: stock, price: price)
end
