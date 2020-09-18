task fcp_vehicle_selector: :environment do
  file = Curb.open_uri(ENV['FCP_STORE'])
  doc = Nokogiri::HTML(file)
  years = doc.css('#yearDropdown').children.text.split("\n")
  years.delete('Year')
  years.each do |year|
    make_url = "#{ENV['FCP_API']}/makes.json?year=#{year}"
    makes = Curb.get(make_url)
    next if makes.blank?

    makes.each do |make|
      base_vehicle_url = "#{ENV['FCP_API']}/base_vehicles.json?year=#{year}&make=#{make['id']}"
      base_vehicles = Curb.get(base_vehicle_url)
      base_vehicles.each do |base_vehicle|
        vehicle_url = "#{ENV['FCP_API']}/vehicles.json?base_vehicle_id=#{base_vehicle['id']}"
        vehicles = Curb.get(vehicle_url)
        vehicles.each do |vehicle|
          body_style_config_url = "#{ENV['FCP_API']}/body_style_configs.json?vehicle_id=#{vehicle['id']}"
          body_style_configs = Curb.get(body_style_config_url)
          body_style_configs.each do |body_style_config|
            engine_configs_url = "#{ENV['FCP_API']}/engine_configs.json?vehicle_id=#{vehicle['id']}&body_id=#{body_style_config['id']}"
            engine_configs = Curb.get(engine_configs_url)
            engine_configs.each do |engine_config|
              transmission_url = "#{ENV['FCP_API']}/transmissions.json?vehicle_id=#{vehicle['id']}&body_id=#{body_style_config['id']}&engine_ids=#{engine_config['id']}"
              transmissions = Curb.get(transmission_url)
              transmissions.each do |transmission|
                params = {
                  year: year,
                  make: make['name'],
                  base_vehicle: base_vehicle['name'],
                  vehicle: vehicle['name'],
                  body_style_config: body_style_config['name'],
                  engine_config: engine_config['name'],
                  transmission: transmission['name']
                }
                # User.select(:year,:make,:base_vehicle,:vehicle,:body_style_config,:engine_config,:transmission).group(:year,:make,:base_vehicle,:vehicle,:body_style_config,:engine_config,:transmission).having("count(*) > 1").size
                VehicleSelector.save(params)
                #puts "Year #{params[:year]} Make #{params[:make]} Base_V #{params[:base_vehicle]} Vehicle #{params[:vehicle]} Body #{params[:body_style_config]} Engine #{params[:engine_config]} Transmission #{params[:transmission]}"
              end
            end
          end
        end
      end
    end
  end
end
