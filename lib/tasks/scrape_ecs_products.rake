desc 'To scrape ecs tuning products from ecstuning.com'
task scrape_ecs_products: :environment do
  store = Store.find_by(name: 'ecstuning')
  sections = %w[/b-genuine-volkswagen-audi-parts/v-audi /b-genuine-volkswagen-audi-parts/v-volkswagen /b-genuine-bmw-parts/v-bmw]
  sections.each do |section|
    url = "#{store.href}#{section}"
    home_doc = Curb.get_doc("#{store.href}#{section}")
    taxons = home_doc.xpath("//div[@class='vselectFacet']").at('ul').css('a')
    taxons.each do |taxon|
      taxon_value = taxon.attributes['href'].value.split('/').last.split('c-').last
      taxon_doc = Curb.get_doc("#{url}/c-#{taxon_value}/")
      # puts "Taxon = #{taxon_value}"
      sub_taxons = taxon_doc.xpath("//script[contains(text(), 'myHREF')]").children.first.text.split('myHREF')
      sub_taxons.each_with_index do |sub_taxon, index|
        if index.odd?
          sub_taxon_value = sub_taxon.split('\;').first.split(" = '").last.split("/'").first.split("c-#{taxon_value}-").last
          break if sub_taxon_value.include? ' = filterVehicleOption.url'

          scrape_ecs_pages(url, store, taxon_value, sub_taxon_value)
          # puts "Value = #{sub_taxon_value}"
        end
      end
      exit if taxon_value.include? 'wheels'
      # puts '******************************************************************************************'
    end
  end
end

def scrape_ecs_pages url, store, taxon_val, sub_taxon_val
  page = 1
  until page.blank?
    page_url = "#{url}/c-#{taxon_val}-#{sub_taxon_val}/#{page}"
    puts "Page: #{page_url}"
    page_doc = Curb.get_doc(page_url)
    products = page_doc.xpath("//div[@class='productListImg col']").css('a')
    products.each_with_index do |product, index|
      product_url = "#{store.href}#{product.attributes['href'].value}"
      product_doc = Curb.get_doc(product_url)
      data = scrap_ecs_product_values(product_doc)
      ecs_product = EcsProduct.find_or_create_by(mfg_number: data[:mfg])
      ecs_product.update(name: data[:name], ecs_number: data[:ecs], brand: data[:brand],
        price: data[:price], availability: data[:availability], details: data[:details],
        href: product_url)
      ecs_product.add_ecs_taxons(taxon_val, sub_taxon_val)
      ecs_product.add_ecs_fitments(product_doc)
      puts "Product:#{index + 1} URL:#{product_url}"
      # puts "MFG#:#{data[:mfg]} ECS#:#{data[:ecs]} Brand:#{data[:brand]} Price:#{data[:price]}"
      # puts "Availability:#{data[:availability]} Title:#{data[:name]}"
      # puts "Details:#{data[:details]}"
      # puts '***********************************************************************************************************************************************'
    rescue StandardError => e
      puts e
      next
    end
    next_page = begin
                  page_doc.xpath('//*[@class="brand_pages"]').last.attributes['href'].value
                rescue StandardError
                  nil
                end
    page += 1
    break if page > next_page.to_i
  end
end

def scrap_ecs_product_values doc
  {
    name: change_encoding(doc.xpath("//h1[@class='producttitle cleanDesc']").children.text),
    mfg: change_encoding(doc.xpath("//dl[@class='dl-horizontal']").css('span')[0].text),
    ecs: change_encoding(doc.xpath("//span[@class='esnum']")[0].children.text),
    brand: change_encoding(doc.xpath("//dl[@class='dl-horizontal']").css('meta')[0].attributes['content'].value),
    price: "$#{change_encoding(doc.xpath("//span[@class='priceproduct ']").children.text)}",
    availability: change_encoding(doc.xpath("//span[@class='stockstatus ']").children.text),
    details: change_encoding(doc.xpath("//div[@class='productlongdesc']").css('p').inner_html.gsub('<br>', '').to_s)
  }
end

def change_encoding str
  str.force_encoding('iso8859-1').encode('utf-8')
end
