desc 'To scrape turn14 items detailed data through api call'
task export_t14_items_data: :environment do
  begin
    token = Curb.t14_auth_token['access_token']
    raise Exception.new "Invalid token" if !token.present?
    item_data_url = "#{ENV['TURN14_STORE']}/v1/items/data?page=1"
    puts item_data_url
    supplier = Supplier.find_or_create_by(supplier_id: 'turn14', name: 'Turn 14')
    loop do
      item_data = Curb.make_get_request(item_data_url, token)
      puts 'start inserting a page into db'
      if item_data['data'].present?
        item_data['data'].each do |data|
          next if data.blank?
          puts 'Turn14 Product added'
          id = data["id"]
          description = data["descriptions"].collect{|x| x["description"]}
          links = data["files"]&.collect{|x| x["links"]}
          links&.each do |link|
            Turn14ProductData.create!(supplier_id: supplier.id, item_id: id, description: description, image: link.first["url"])
          end
        end
      end
      if item_data['links']['next'].nil?
        raise Exception.new "Exiting the script"
        exit 
      end
      item_data_url = ENV['TURN14_STORE'] + item_data['links']['next']
      puts item_data_url
    rescue StandardError => e
      puts "exception #{e}"
      sleep 1
      token = Curb.t14_auth_token['access_token']
      retry
    end
  rescue Exception => e
    if !e.message.eql?("Exiting the script")
      puts e.message
      UserMailer.with(user: e, script: "export_t14_items").issue_in_script.deliver_now
    end
  end
end
