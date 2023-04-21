require 'net/ftp'
require 'zip'
require 'csv'
desc 'To scrape keystone, ftp catalog'

task keystone: :environment do
    begin
        file = File.open("Inventory.csv")
        data = file.readlines
        puts data[0].split(",")
        data[0] = nil
        data = data.compact

        data.each do |row|
            row = row.split(",")
            vendor_name = row[0].delete("\"=\n\r")
            vcpn = row[1].delete("\"=\n\r")
            vendor_code = row[2].delete("\"=\n\r")
            part_number = row[3].delete("\"=\n\r")
            manufacturer_part_no = row[4].delete("\"=\n\r")
            long_description = row[5].delete("\"=\n\r")
            jobber_price = row[6].delete("\"=\n\r")
            cost = row[7].delete("\"=\n\r")
            ups_able = row[8].delete("\"=\n\r")
            core_charge = row[9].delete("\"=\n\r")
            case_qty = row[10].delete("\"=\n\r").to_f
            is_non_returnable = row[11].delete("\"=\n\r")
            upc_code = row[13].delete("\"=\n\r")
            total_qty = row[32].delete("\"=\n\r").to_f
            kit_components = row[33].delete("\"=\n\r")
            is_kit = row[34].delete("\"=\n\r")

            puts "vendor_name: #{vendor_name},   vcpn: #{vcpn},   vendor_code: #{vendor_code},   part_number: #{part_number},   manufacturer_part_no: #{manufacturer_part_no},"
            puts "long_description: #{long_description},   jobber_price: #{jobber_price},   cost: #{cost},   ups_able: #{ups_able},   core_charge: #{core_charge},   case_qty: #{case_qty},"
            puts "is_non_returnable: #{is_non_returnable},   upc_code: #{upc_code},   total_qty: #{total_qty},   kit_components: #{kit_components},    is_kit: #{is_kit}"
            puts "**********************************************************************************************************************************"
            
            product = KeystoneProduct.find_or_create_by(vcpn: vcpn, part_number: part_number)
            product.update(vendor_name: vendor_name, vcpn: vcpn, vendor_code: vendor_code, part_number: part_number, manufacturer_part_no: manufacturer_part_no, long_description: long_description, jobber_price: jobber_price, cost: cost, ups_able: ups_able, core_charge: core_charge, case_qty: case_qty, is_non_returnable: is_non_returnable, upc_code: upc_code, total_qty: total_qty, kit_components: kit_components, is_kit: is_kit)
        end
    end
end