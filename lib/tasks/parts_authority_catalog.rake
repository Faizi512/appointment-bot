require 'net/ftp'
require 'zip'
require 'skylight'
# Skylight.start!

desc 'To scrape parts authority products catalog'

# Skylight.instrument(title: 'parts_autority span') do
  task parts_authority_catalog: :environment do
    begin
      # store = Store.find_by(store_id: 'vividracing')
      arr = []
      ftp = Net::FTP.new('pareps.panetny.com')
      ftp.login('moddeurospf','DmZ7e44k')
      raise Exception.new "Login failed" if !ftp.welcome.present?
      count = 0
      ftp.passive = true
      puts "----- Getting Zip file -----"
      ftp.getbinaryfile('partsauthority.zip', 'zip_parts_authority', 1024) # 1024 is representing blocksize
      Zip::File.open('zip_parts_authority') do |zip_file|
        raise Exception.new "Date not found" if !zip_file.present?
        zip_file.each do |entry|
          puts "Unzip #{entry.name}"
          content = entry.get_input_stream.read.force_encoding('ISO-8859-1').encode('UTF-8')
          CSV.parse(content, headers: true, header_converters: :symbol) do |row|
            # puts "Line #{row[:line]} Part #{row[:part]} Cost #{row[:cost]} Count #{row[:qtyonhand]} Packs #{row[:packs]} Brand: #{row[:brand]}"
            product = PartAuthorityProduct.find_or_create_by(part_number: row[:part], product_line: row[:line])
            product.update(product_line: row[:line], price: row[:cost], core_price: row[:coreprice], qty_on_hand: row[:qtyonhand], packs: row[:packs], brand: row[:brand], present_in_file: true)
            #puts product.inspect
            count = count + 1
            puts count
          end
        end
      end 

      ftp.close
      PartAuthorityProduct.where(present_in_file: [false, nil]).collect{|e| e.update!(qty_on_hand: 0, present_in_file: false)}
    rescue Exception=> e
      puts e.message
      UserMailer.with(user: e, script: "parts_authority_catalog").issue_in_script.deliver_now
    end
  end
# end