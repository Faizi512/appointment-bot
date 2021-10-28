desc 'To scrape vehicle selector data of AUDI, Volkswagen from fcpeuro.com'
task fcp_vehicle_selector: :environment do
  begin
    file = Curb.open_uri(ENV['FCP_STORE'])
    doc = Nokogiri::HTML(file)
    raise Exception.new "Doc not found" if !doc.present?
  rescue Exception => e
    puts e.message
    UserMailer.with(user: e, script: "fcp_vehicle_selector").issue_in_script.deliver_now
  end
  years = doc.css('#yearDropdown').children.text.split("\n")
  years.delete('Year')
  years.each do |year|
    make_url = "#{ENV['FCP_API']}/makes.json?year=#{year}"
    makes = Curb.get(make_url)
    next if makes.blank?

    makes.each do |make|
      base_vehicle_url = "#{ENV['FCP_API']}/base_vehicles.json?year=#{year}&make=#{make['id']}"
      base_vehicles = Curb.get(base_vehicle_url)
      next if base_vehicles.blank?

      base_vehicles.each do |base_vehicle|
        vehicle_url = "#{ENV['FCP_API']}/vehicles.json?base_vehicle_id=#{base_vehicle['id']}"
        vehicles = Curb.get(vehicle_url)
        next if vehicles.blank?
        
        vehicles.each do |vehicle|
          body_style_config_url = "#{ENV['FCP_API']}/body_style_configs.json?vehicle_id=#{vehicle['id']}"
          body_style_configs = Curb.get(body_style_config_url)
          next if body_style_configs.blank?
          
          body_style_configs.each do |body_style_config|
            engine_configs_url = "#{ENV['FCP_API']}/engine_configs.json?vehicle_id=#{vehicle['id']}&body_id=#{body_style_config['id']}"
            engine_configs = Curb.get(engine_configs_url)
            next if engine_configs.blank?
            
            engine_configs.each do |engine_config|
              transmission_url = "#{ENV['FCP_API']}/transmissions.json?vehicle_id=#{vehicle['id']}&body_id=#{body_style_config['id']}&engine_ids=#{engine_config['id']}"
              transmissions = Curb.get(transmission_url)
              next if transmissions.blank?
              
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
                VehicleSelector.find_or_create_by(params)
                # puts "Year #{params[:year]} Make #{params[:make]} Base_V #{params[:base_vehicle]} Vehicle #{params[:vehicle]} Body #{params[:body_style_config]} Engine #{params[:engine_config]} Transmission #{params[:transmission]}"
              end
            end
          end
        end
      end
    end
  end
end
