desc 'To scrape fcpeuro products from fcpeuro.com'
task scrape_fcp_products: :environment do
  sections = []
  # sections << Section.find_by(section_id: "Audi-parts")
  # sections << Section.find_by(section_id: "Volkswagen-parts")
  sections << Section.find_by(section_id: ENV["SECTION_ID"])
  section = sections.first
  arr = (1..ENV["PAGE_NUMBER"].to_i).to_a  # create an array of length 250
# ======================================================================
  threads = []
  # pages = []
  # byebug
  (arr.count/100.0).ceil.to_i.times do |i|
    sleep(1)
    threads << Thread.new(i) do |idx|
      start_idx = idx * 100  # starting index for this thread's slice
      end_idx = start_idx + 99  # ending index for this thread's slice
      page_numbers = arr[start_idx..end_idx]  # get the slice of the array to process

      # process the slice
      page_numbers.each do |page|
        # your processing code here
        # puts "href:  #{sections.first.href}?page=#{page_number}"
        # pages << page_number

        begin
          puts "====================================================="
          puts "                    page # #{page}"
          puts "====================================================="
          puts "href:  #{section.href}?page=#{page}"
          puts "====================================================="
          file = Curb.open_uri(section.href + "?page=#{page}")
          begin
            doc = Nokogiri::HTML(file)
          raise Exceptio.new "Doc not found" if !doc.present?
          rescue Exception => e
            puts e.message
            UserMailer.with(user: e, script: "scrape_fcp_products").issue_in_script.deliver_now
          end
          doc.css('.browse .group').each_with_index do |group, index1|
            category_name = group.css('.group__heading .crumbs__item .crumbs__name').last.text rescue nil
            if category_name.blank?
              category_name = group.css('.group__heading .crumbs__item span').text.split("Home").second rescue nil
            end
            category = section.categories.find_or_create_by(name: category_name)
            puts "Category #{index1} Name: #{category.name}"
            group.css('.grid-x.hit').each_with_index do |item,index2|
              item_url = "#{ENV['FCP_STORE']}#{item['data-href']}"
              item_doc = Nokogiri::HTML(Curb.open_uri(item_url)) 
              sleep(1)
              if item_doc.children.count <= 1
                item_doc_retry = Nokogiri::HTML(Curb.open_uri(item_url)) 
                puts "Item skipped: Because item not found at :> #{item_url}" if item_doc_retry.children.count <= 1
                next if item_doc_retry.children.count <= 1
              end
              # sku = item_doc.at('.//meta[@itemprop=$value]', nil, { value: 'sku' })['content']
              sku = item_doc.xpath('/html/body/div[3]/div/div/div/div[2]/div[2]/div/div[2]/div[1]/div[2]/span[2]').text().strip
              async_url = "#{ENV['FCP_STORE']}#{item_doc.at('.extended')['data-load-async']}"
              async_doc = Nokogiri::HTML(Curb.open_uri(async_url))
              sleep(1)
              # desc = async_doc.at('#description').at('.extended__details').css('h3').css('li').text.strip 
              desc = async_doc.at('#description').at('.extended__details').css('dl').css('dd').text.strip
              if async_doc.css('.extended__kit').present?
                puts "Kit #{index2}"
                kit = category.kits.find_by(sku: sku)
                if kit.blank?
                  kit = category.kits.create(scrap_fcp_values(item_doc, desc, async_doc, item_url))
                else
                  kit.update!(scrap_fcp_values(item_doc, desc, async_doc, item_url))
                  sku_list = async_doc.css('.extended__kit table tbody tr .extended__tableSku').text.strip.split("\n").reject { |s| s.empty? }
                  qty_list = async_doc.css('.extended__kit table tbody tr td:first-child').text.strip.split("\n").reject { |s| s.empty? }
                  price_list = async_doc.css('.extended__kit table tbody tr td:last-child').text.strip.gsub("$", "").split("\n").reject { |s| s.empty? }
                  href_list= async_doc.css('.extended__kit table tbody tr td[2]').collect {|n| ENV["FCP_STORE"]+n.children[1].values.first}
                  sku_list.each_with_index do |product_sku,index3|
                    prod = category.fcp_products.find_or_create_by(sku: product_sku)
                    prod.update!(price: price_list[index3], qty: qty_list[index3], href: href_list[index3])
                    pk = kit.fcp_product_kits.find_or_create_by(fcp_product: prod)
                    puts "#{index3} Product of kit inserted" if pk.present?
                    puts prod.inspect if pk.present?
                  end
                end
                add_fcp_fitments(async_doc, kit)
              else
                puts "#{index2} Product single inserted"
                product = category.fcp_products.find_by(sku: sku)
                if product.blank?
                  product = category.fcp_products.find_or_create_by(scrap_fcp_values(item_doc, desc, async_doc, item_url))
                else
                  product = category.fcp_products.find_or_create_by(scrap_fcp_values(item_doc, desc, async_doc, item_url))
                end
                puts "==========#{product}========="
                add_fcp_fitments(async_doc, product)
              end
            end
          end
          next_page = begin
                        sleep(1)
                        doc.css('.pages .pages__link').at('a[rel=next]')["href"]
                        sleep(1)
                      rescue SignalException => e
                        nil
                      rescue StandardError => e
                        puts e.message
                        UserMailer.with(user: e, script: "scrape_fcp_products").issue_in_script.deliver_now
                      end
          break if next_page.blank?
          puts "Next Page: #{next_page}"
          page = next_page.split('page=')[1]
        rescue
          break
        end
      end
    end
  end

  threads.each(&:join)  # wait for all threads to finish
  # byebug
# ======================================================================

  # sections.each do |section|
  #   puts "====================================================="
  #   puts "              Section: #{section.section_id}"
  #   puts "====================================================="
  #   page = ENV["PAGE_NUMBER"]
  #   until page.blank?
  #     begin
  #       puts "====================================================="
  #       puts "                    page # #{page}"
  #       puts "====================================================="
  #       puts "href:  #{section.href}?page=#{page}"
  #       puts "====================================================="
  #       file = Curb.open_uri(section.href + "?page=#{page}")
  #       begin
  #         doc = Nokogiri::HTML(file)
  #       raise Exceptio.new "Doc not found" if !doc.present?
  #       rescue Exception => e
  #         puts e.message
  #         UserMailer.with(user: e, script: "scrape_fcp_products").issue_in_script.deliver_now
  #       end
  #       doc.css('.browse .group').each_with_index do |group, index1|
  #         category_name = group.css('.group__heading .crumbs__item .crumbs__name').last.text rescue nil
  #         if category_name.blank?
  #           category_name = group.css('.group__heading .crumbs__item span').text.split("Home").second rescue nil
  #         end
  #         category = section.categories.find_or_create_by(name: category_name)
  #         puts "Category #{index1} Name: #{category.name}"
  #         group.css('.grid-x.hit').each_with_index do |item,index2|
  #           item_url = "#{ENV['FCP_STORE']}#{item['data-href']}"
  #           item_doc = Nokogiri::HTML(Curb.open_uri(item_url)) 
  #           if item_doc.children.count <= 1
  #             item_doc_retry = Nokogiri::HTML(Curb.open_uri(item_url)) 
  #             puts "Item skipped: Because item not found at :> #{item_url}" if item_doc_retry.children.count <= 1
  #             next if item_doc_retry.children.count <= 1
  #           end
  #           # sku = item_doc.at('.//meta[@itemprop=$value]', nil, { value: 'sku' })['content']
  #           sku = item_doc.xpath('/html/body/div[3]/div/div/div/div[2]/div[2]/div/div[2]/div[1]/div[2]/span[2]').text().strip
  #           async_url = "#{ENV['FCP_STORE']}#{item_doc.at('.extended')['data-load-async']}"
  #           async_doc = Nokogiri::HTML(Curb.open_uri(async_url))
  #           # desc = async_doc.at('#description').at('.extended__details').css('h3').css('li').text.strip 
  #           desc = async_doc.at('#description').at('.extended__details').css('dl').css('dd').text.strip
  #           if async_doc.css('.extended__kit').present?
  #             puts "Kit #{index2}"
  #             kit = category.kits.find_by(sku: sku)
  #             if kit.blank?
  #               kit = category.kits.create(scrap_fcp_values(item_doc, desc, async_doc, item_url))
  #             else
  #               kit.update!(scrap_fcp_values(item_doc, desc, async_doc, item_url))
  #               sku_list = async_doc.css('.extended__kit table tbody tr .extended__tableSku').text.strip.split("\n").reject { |s| s.empty? }
  #               qty_list = async_doc.css('.extended__kit table tbody tr td:first-child').text.strip.split("\n").reject { |s| s.empty? }
  #               price_list = async_doc.css('.extended__kit table tbody tr td:last-child').text.strip.gsub("$", "").split("\n").reject { |s| s.empty? }
  #               href_list= async_doc.css('.extended__kit table tbody tr td[2]').collect {|n| ENV["FCP_STORE"]+n.children[1].values.first}
  #               sku_list.each_with_index do |product_sku,index3|
  #                 prod = category.fcp_products.find_or_create_by(sku: product_sku)
  #                 prod.update!(price: price_list[index3], qty: qty_list[index3], href: href_list[index3])
  #                 pk = kit.fcp_product_kits.find_or_create_by(fcp_product: prod)
  #                 puts "#{index3} Product of kit inserted" if pk.present?
  #                 puts prod.inspect if pk.present?
  #               end
  #             end
  #             add_fcp_fitments(async_doc, kit)
  #           else
  #             puts "#{index2} Product single inserted"
  #             product = category.fcp_products.find_by(sku: sku)
  #             if product.blank?
  #               product = category.fcp_products.find_or_create_by(scrap_fcp_values(item_doc, desc, async_doc, item_url))
  #             else
  #               product = category.fcp_products.find_or_create_by(scrap_fcp_values(item_doc, desc, async_doc, item_url))
  #             end
  #             puts "==========#{product}========="
  #             add_fcp_fitments(async_doc, product)
  #           end
  #         end
  #       end
  #       next_page = begin
  #                     doc.css('.pages .pages__link').at('a[rel=next]')["href"]
  #                   rescue SignalException => e
  #                     nil
  #                   rescue StandardError => e
  #                     puts e.message
  #                     UserMailer.with(user: e, script: "scrape_fcp_products").issue_in_script.deliver_now
  #                   end
  #       break if next_page.blank?
  #       puts "Next Page: #{next_page}"
  #       page = next_page.split('page=')[1]
  #     rescue
  #       break
  #     end
  #   end
  # end
end

def add_fcp_fitments doc, product
  doc.at('#fitment').css('.fitmentGuide .fitmentGuide__models .fitmentGuide__applicationGroup').css('ul').css('li').each do |li| 
    model = li.at('div').text.strip
    product.fitments.find_or_create_by(fitment_model: model)
  end
end

def scrap_fcp_values item_doc, desc, async_doc, item_url
  begin
    params = 
    {
      title: item_doc.at('.listing__name').text.strip,
      brand: item_doc.at('.//meta[@property=$value]', nil, { value: 'product:brand' })['content'],
      price: item_doc.at('.listing__price .listing__amount span').text.gsub('$', ""),
      available_at: item_doc.at('.listing__fulfillmentDesc span').text,
      # sku: item_doc.at('.//meta[@itemprop=$value]', nil, { value: 'sku' })['content'],
      sku: item_doc.xpath('/html/body/div[3]/div/div/div/div[2]/div[2]/div/div[2]/div[1]/div[2]/span[2]').text().strip,
      # fcp_euro_id: desc.split("FCP Euro ID:\n")[1].split("\n")[0],
      fcp_euro_id: desc.split("\n")[0],
      # quality: desc.split("Quality:\n")[1].split("\n")[0],
      quality: desc.split("\n")[3],
      # oe_numbers: async_doc.at('.extended__oeNumbers').text.strip.split("OE Numbers\n")[1],
      oe_numbers: async_doc.at('.extended__oeNumbers').text.strip.split("OE Numbers\n")[1].strip,
      mfg_numbers: async_doc.at('.extended__mfgNumbers').text.strip.split("MFG Numbers\n")[1].strip,
      href: item_url
    }
  rescue
    continue
  end
end