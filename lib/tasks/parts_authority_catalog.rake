require 'net/ftp'
require 'zip'
desc 'To scrape parts authority products catalog'
task parts_authority_catalog: :environment do
  begin
    ftp = Net::FTP.new('ftp.panetny.com')
    ftp.login('moddeurospf','DmZ7e44k')
    raise Exception.new "Login failed" if !ftp.welcome.present?
    ftp.passive = true
    ftp.getbinaryfile('partsauthority.zip', 'zip_parts_authority', 1024) # 1024 is representing blocksize
    Zip::File.open('zip_parts_authority') do |zip_file|
      raise Exception.new "Date not found" if !zip_file.present?
      zip_file.each do |entry|
        puts "Unzip #{entry.name}"
        content = entry.get_input_stream.read
        CSV.parse(content, headers: true, header_converters: :symbol) do |row|
          puts "Line #{row[:line]} Part #{row[:part]} Cost #{row[:cost]} Count #{row[:qtyonhand]} Packs #{row[:packs]} Brand: #{row[:brand]}"
          product = PartAuthorityProduct.find_or_create_by(part_number: row[:part], product_line: row[:line])
          product.update(product_line: row[:line], price: row[:cost], core_price: row[:coreprice], qty_on_hand: row[:qtyonhand], packs: row[:packs], brand: row[:brand])
        end
      end
    end

    ftp.close
  rescue Exception=> e
    puts e.message
    UserMailer.with(user: e, script: "parts_authority_catalog").issue_in_script.deliver_now
  end
end
