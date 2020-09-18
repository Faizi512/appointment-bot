# frozen_string_literal: true

task scrape_fcp_products: :environment do
  section_ids = %w[Audi-parts]
  section_ids.each do |id|
    section = Section.find_by(section_id: id)
    # byebug    
    page = 1
    until page.blank?
      file = Curb.open_uri(section.href + "?page=#{page}")
      doc = Nokogiri::HTML(file)
      doc.css('.browse .group').each_with_index do |group, index1|
        category_name = group.css('.group__heading .crumbs__item .crumbs__name').last.text
        category = section.categories.find_or_create_by(name: category_name)
        # puts "Category #{index1} Name: #{category.name}"
        group.css('.grid-x.hit').each_with_index do |item,index2|
          item_url = "#{ENV['FCP_STORE']}/#{item['data-href']}"
          item_doc = Nokogiri::HTML(Curb.open_uri(item_url))
          sku = item_doc.at('.//meta[@itemprop=$value]', nil, { value: 'sku' })['content']
          async_url = "#{ENV['FCP_STORE']}#{item_doc.at('.extended')['data-load-async']}"
          async_doc = Nokogiri::HTML(Curb.open_uri(async_url))
          desc = async_doc.at('#description').at('.extended__details').css('ul').css('li').text.strip
          if async_doc.css('.extended__kit')
            # puts "Kit #{index2}"
            kit = category.kits.find_or_create_by({
                                         title: item_doc.at('.listing__name').text.strip,
                                         brand: item_doc.at('.//meta[@property=$value]', nil, { value: 'product:brand' })['content'],
                                         sku: item_doc.at('.//meta[@itemprop=$value]', nil, { value: 'sku' })['content'],
                                         price: item_doc.at('.listing__price .listing__amount span').text,
                                         available_at: item_doc.at('.listing__fulfillmentDesc span').text,
                                         fcp_euro_id: desc.split("FCP Euro ID:\n")[1].split("\n")[0],
                                         quality: desc.split("Quality:\n")[1].split("\n")[0],
                                         oe_numbers: async_doc.at('.extended__oeNumbers').text.strip.split("OE Numbers\n")[1],
                                         mfg_numbers: async_doc.at('.extended__mfgNumbers').text.strip.split("MFG Numbers\n")[1],
                                         href: item_url
                                       })
            sku_list = async_doc.css('.extended__kit table tbody tr .extended__tableSku').text.strip.split("\n").reject { |s| s.empty? }
            sku_list.each_with_index do |product_sku,index3|
              prod = category.fcp_products.find_or_create_by(sku: product_sku)
              pk = kit.fcp_product_kits.find_or_create_by(fcp_product: prod)
              # puts "#{index3} Product of kit inserted" if pk.present?
            end
          else
            puts "#{index2} Product single inserted"
            category.fcp_products.find_or_create_by(sku: sku).update({
                                                                       title: item_doc.at('.listing__name').text.strip,
                                                                       brand: item_doc.at('.//meta[@property=$value]', nil, { value: 'product:brand' })['content'],
                                                                       price: item_doc.at('.listing__price .listing__amount span').text,
                                                                       available_at: item_doc.at('.listing__fulfillmentDesc span').text,
                                                                       fcp_euro_id: desc.split("FCP Euro ID:\n")[1].split("\n")[0],
                                                                       quality: desc.split("Quality:\n")[1].split("\n")[0],
                                                                       oe_numbers: async_doc.at('.extended__oeNumbers').text.strip.split("OE Numbers\n")[1],
                                                                       mfg_numbers: async_doc.at('.extended__mfgNumbers').text.strip.split("MFG Numbers\n")[1],
                                                                       href: item_url
                                                                     })
          end
        end
      end
      next_page = begin
                    doc.css('.pages .pages__link').at('a[rel=next]')["href"]
                  rescue StandardError
                    nil
                  end
      puts "Next Page: #{next_page}"
      page = next_page.split('page=')[1]
    end
  end
end
