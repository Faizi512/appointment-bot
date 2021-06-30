require 'roo'
desc "Upload data from files(xlsx or csv) to heroku table"
task push_data: :environment do
    workbook = Roo::Spreadsheet.open("#{Rails.root}/app/DataFiles/parts_authority_solidus_products.xlsx", extension: :xlsx)
    worksheets = workbook.sheets
    puts "Found #{worksheets.count} worksheets"
    
    worksheets.each do |worksheet|
        puts "Reading: #{worksheet}"
        num_rows = 0
        workbook.sheet(worksheet).each do |row|
        if num_rows > 0
            brand = row[1]
            mpn = row[3]
            sku = row[0]
            name = row[2]
            puts "Brand: #{brand}, mpn: #{mpn}, sku: #{sku}, name: #{name}"
            product = PartAuthorityBrandsMpn.find_or_create_by(brand: brand, mpn: mpn)
            product.update(brand: brand, mpn: mpn, sku: sku, product_name: name)
        end
        num_rows += 1
        end
        puts "Read #{num_rows} rows" 
    end
end