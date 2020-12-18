task scrape_ebay_products: :environment do
  store = Store.find_by(name: 'ebay')
  home_doc = Curb.get_doc(store.href)
  products_url = home_doc.css('ul').css('li').css('h3').css('a')
  byebug
  puts "Products #{products_url.count} Fetched"
  products_url.each_with_index do |product_url, index|
    url = product_url.attributes['href'].value
    # url = 'https://www.ebay.com/itm/MDI-Adapter-Cable-3-5mm-AUX-Beetle-CC-Golf-GTI-Jetta-Passat-R-000-051-446-D/293452129091?hash=item44531c2343:g:wQ0AAOSwrcReMz-x'
    product_doc = Curb.get_doc(url)
  	# byebug
    # title = product_doc.css('h1').children.last
    title = product_doc.xpath('.//h1[@id=$value]', nil, { value: 'itemTitle' }).children.text.split('Details about  ').last
    sku = product_doc.xpath('.//h2[@itemprop=$value]', nil, { value: 'mpn' }).children.text
    price = product_doc.xpath('.//span[@itemprop=$value]', nil, { value: 'price' }).children.text.split(' ').last
    batch = product_doc.xpath('.//span[@id=$value]', nil, { value: 'qtySubTxt' })
    qty = batch.children[1].children.text.strip.split(' ').first if batch.present?
    puts "URL: #{url}"
    puts "Title: #{title}"
    puts "Index: #{index+1} SKU: #{sku} Price #{price} QTY: #{qty}"
    puts "\n"
    item = EbayProduct.find_or_create_by(sku: sku)
    item.update(title: title, price: price, qty: qty, href: url)
  end
end