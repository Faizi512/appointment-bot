task :scrape_fcp_products => :environment do
    section_ids = ["Volkswagen-parts", "Audi-parts"]
    section_ids.each do |id|
        section  = Section.find_by(section_id: id)
        file = Curb.open_uri(section.href)
        doc = Nokogiri::HTML(file)
        doc.css('.browse .group').each do |group|
            category_name = group.css('.group__heading .crumbs__item .crumbs__name').last.text
            category = section.categories.create(name:category_name)
            group.css('.grid-x.hit').each do |item|
                Item_url = "#{ENV["FCP_STORE"]}/#{item["data-href"]}"
                item_doc = Nokogiri::HTML(Curb.open_uri(Item_url))
                sku = item_doc.at('.//meta[@itemprop=$value]', nil, {:value => 'sku'})["content"]
                async_url = "#{ENV["FCP_STORE"]}#{item_doc.at('.extended')["data-load-async"]}"
                async_doc = Nokogiri::HTML(Curb.open_uri(async_url))
                desc = async_doc.at("#description").at('.extended__details').css('ul').css('li').text.strip
                if async_doc.css('.extended__kit')
                    kit = category.kits.create({
                        title: item_doc.at('.listing__name').text.strip,
                        brand: item_doc.at('.//meta[@property=$value]', nil, {:value => 'product:brand'})["content"],
                        sku: item_doc.at('.//meta[@itemprop=$value]', nil, {:value => 'sku'})["content"],
                        price: item_doc.at('.listing__price .listing__amount span').text,
                        available_at: item_doc.at('.listing__fulfillmentDesc span').text,
                        fcp_euro_id: desc.split("FCP Euro ID:\n")[1].split("\n")[0],
                        quality: desc.split("Quality:\n")[1].split("\n")[0],
                        oe_numbers: async_doc.at('.extended__oeNumbers').text.strip.split("OE Numbers\n")[1],
                        mfg_numbers: async_doc.at('.extended__mfgNumbers').text.strip.split("MFG Numbers\n")[1],
                        href: Item_url
                    })
                    sku_list = async_doc.css('.extended__kit table tbody tr .extended__tableSku').text.strip.split("\n").reject { |s| s.empty? }
                    sku_list.each do |product_sku|
                        byebug
                        # kit.fcp_product_kits.find_or_create_by(fcp_product: FcpProduct.find_or_create_by(sku: product_sku))
                        # kit.fcp_product_kits.find_by(fcp_product: FcpProduct.find_by(sku: product_sku))#fcp_products.find_or_create_by(sku: product_sku)
                        # category.fcp_products.first.fcp_product_kits
                    end
                else
                    category.fcp_products.find_or_create_by(sku: sku).update({
                        title: item_doc.at('.listing__name').text.strip,
                        brand: item_doc.at('.//meta[@property=$value]', nil, {:value => 'product:brand'})["content"],
                        price: item_doc.at('.listing__price .listing__amount span').text,
                        available_at: item_doc.at('.listing__fulfillmentDesc span').text,
                        fcp_euro_id: desc.split("FCP Euro ID:\n")[1].split("\n")[0],
                        quality: desc.split("Quality:\n")[1].split("\n")[0],
                        oe_numbers: async_doc.at('.extended__oeNumbers').text.strip.split("OE Numbers\n")[1],
                        mfg_numbers: async_doc.at('.extended__mfgNumbers').text.strip.split("MFG Numbers\n")[1],
                        href: Item_url
                    })
                end
            end
        end
        # byebug
        # doc.css('.pages .pages__link').each do |link| puts link end
        # doc.css('.pages .pages__link').css("[rel]").first.attributes
        next_page = doc.css('.pages .pages__link').css("[rel]").first.attributes["href"].value rescue nil
        exit if next_page.blank?
        # section
        # make_url = "#{ENV["FCP_STORE"]}/#{section}"
    end
end