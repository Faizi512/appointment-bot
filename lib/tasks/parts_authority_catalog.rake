desc 'To check parts authority products catalog'

require 'net/ftp'
require 'zip'
task parts_authority_catalog: :environment do
  ftp = Net::FTP.new('ftp.panetny.com')
  ftp.login('moddeurospf', 'DmZ7e44k')
  ftp.passive = true
  ftp.getbinaryfile('partsauthority.zip', 'zip_parts_authority', 1024) # 1024 is representing blocksize
  Zip::File.open('zip_parts_authority') do |zip_file|
    zip_file.each do |entry|
      puts "Unzip #{entry.name}"
      content = entry.get_input_stream.read
      CSV.parse(content, headers: true, header_converters: :symbol) do |row|
        puts "Line #{row[:line]} Part #{row[:part]} Cost #{row[:cost]} Count #{row[:qtyonhand]} Packs #{row[:packs]}"
        product = PartAuthorityProduct.find_or_create_by(part_number: row[:part])
        product.update(product_line: row[:line], price: row[:cost], core_price: row[:coreprice], qty_on_hand: row[:qtyonhand], packs: row[:packs])
      end
    end
  end

  ftp.close
end
