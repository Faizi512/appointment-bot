task scrape_ecs_products: :environment do
  store = Store.find_by(name: 'ecstuning')
  sections = %w[/b-genuine-bmw-parts/v-bmw /b-genuine-volkswagen-audi-parts]
  sections.each do |section|
    url = "#{store.href}#{section}"
    # home_url = "#{store.href}#{section}"
    # home_doc = Curb.get_doc(home_url)
    # taxons = home_doc.xpath("//div[@class='vselectFacet']").at('ul').css('a')
    # taxons.each do |taxon|
    #   taxon_value = taxon.attributes['href'].value.split('/').last.split('c-').last
    #   taxon_url = "#{store.href}#{taxon.attributes['href'].value}"
    #   puts "#{taxon_url}"
    #   taxon_doc = Curb.get_doc(taxon_url)
    #   sub_taxons = taxon_doc.xpath("//div[@class='childFacets']").at('ul').css('a')
    # end
    scrape_ecs_pages(url, store)
  end
end

def scrape_ecs_pages page_url, store
  page = 1
  until page.blank?
    puts "Page: #{page_url}/#{page}"
    page_doc = Curb.get_doc(page_url + "/#{page}")
    products = page_doc.xpath("//div[@class='productListImg col']").css('a')
    products.each_with_index do |product, index|
      product_url = "#{store.href}#{product.attributes['href'].value}"
      product_doc = Curb.get_doc(product_url)
      data = scrap_ecs_product_values(product_doc)
      product = EcsProduct.find_or_create_by(mfg_number: data[:mfg])
      product.update(name: data[:name], ecs_number: data[:ecs], brand: data[:brand], price: data[:price],
        availability: data[:availability], details: data[:details], href: product_url)
      puts "Product:#{index + 1} URL:#{product_url}"
      # puts "MFG#:#{data[:mfg]} ECS#:#{data[:ecs]} Brand:#{data[:brand]} Price:#{data[:price]}"
      # puts "Availability:#{data[:availability]} Title:#{data[:name]}"
      # puts "Details:#{data[:details]}"
      add_ecs_fitments(product_doc, product)
      # puts '***********************************************************************************************************************************************'
    end
    next_page = begin
                  page_doc.xpath('//*[@class="brand_pages"]').last.attributes['href'].value
                rescue StandardError
                  nil
                end
    break if page > next_page.to_i

    page += 1
  end
end

def scrap_ecs_product_values doc
  {
    name: doc.xpath("//h1[@class='producttitle cleanDesc']").children.text,
    mfg: doc.xpath("//dl[@class='dl-horizontal']").css('span')[0].text,
    ecs: doc.xpath("//span[@class='esnum']")[0].children.text,
    brand: doc.xpath("//dl[@class='dl-horizontal']").css('meta')[0].attributes['content'].value,
    price: "$#{doc.xpath("//span[@class='priceproduct ']").children.text}",
    availability: doc.xpath("//span[@class='stockstatus ']").children.text,
    details: doc.xpath("//div[@class='productlongdesc']").css('p').inner_html.gsub('<br>', '')
  }
end

def add_ecs_fitments doc, product
  rows = doc.xpath("//table[@class='appTable']").css('tr')
  rows.each_with_index do |row, index|
    next if index.zero?

    make = row.children[1].children.text
    modal = row.children[3].children.text
    submodal = row.children[5].children.text
    engine = row.children[7].children.text
    product.ecs_fitments.find_or_create_by(make: make, model: modal, sub_model: submodal, engine: engine)
  end
end
