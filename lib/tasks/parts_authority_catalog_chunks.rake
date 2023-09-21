require 'net/ftp'
require 'zip'
require 'csv'
require 'skylight'
require 'fileutils'

desc 'To scrape parts authority products catalog'

task parts_authority_catalog_chunks: :environment do
  begin
    arr = []
    ftp = Net::FTP.new('pareps.panetny.com')
    ftp.login('moddeurospf','DmZ7e44k')
    raise Exception.new "Login failed" if !ftp.welcome.present?
    ftp.passive = true
    puts "----- Getting Zip file -----"
    ftp.getbinaryfile('partsauthority.zip', 'zip_parts_authority', 1024) # 1024 is representing blocksize
    FileUtils.rm_rf('parts_authority_catalog_csv_files') if Dir.exist?('parts_authority_catalog_csv_files')
    Dir.mkdir('parts_authority_catalog_csv_files') unless Dir.exist?('parts_authority_catalog_csv_files')

    chunk_size = 800000 # Adjust the chunk size as needed
    current_chunk = 1
    count = 0

      Zip::File.open('zip_parts_authority') do |zip_file|
        raise Exception.new "Date not found" if !zip_file.present?
        current_chunk_rows = []
        zip_file.each do |entry|
          puts "Unzip #{entry.name}"
          content = entry.get_input_stream.read.force_encoding('ISO-8859-1').encode('UTF-8')
        
          begin
            CSV.parse(content, headers: true, header_converters: :symbol) do |row|
              # Process each row and add it to the current chunk
              current_chunk_rows << row
        
              # Check if the current chunk size has been reached
              if current_chunk_rows.length >= chunk_size
                # Write the current chunk to a CSV file
                csv_filename = "parts_authority_chunk_#{current_chunk}.csv"
                CSV.open("parts_authority_catalog_csv_files/#{csv_filename}", 'w', headers: true) do |csv|
                  csv << current_chunk_rows.first.headers
                  current_chunk_rows.each { |chunk_row| csv << chunk_row } 
                  count = count + 1
                  puts count
                end
        
                # Increment the chunk counter and reset the current_chunk_rows array
                current_chunk += 1
                current_chunk_rows = []
              end
            end
          rescue CSV::MalformedCSVError => e
            puts "Error processing CSV: #{e.message}"
          end
        end

        # Check if there are any remaining rows in the current_chunk_rows array
        if current_chunk_rows.any?
          # Write the remaining rows to a CSV file
          csv_filename = "parts_authority_chunk_#{current_chunk}.csv"
          CSV.open("parts_authority_catalog_csv_files/#{csv_filename}", 'w', headers: true) do |csv|
            csv << current_chunk_rows.first.headers # Write headers
            current_chunk_rows.each { |chunk_row| csv << chunk_row } # Write rows
            count = count + 1
            puts count
          end
        end
      end
    ftp.close
    PartAuthorityProduct.where(present_in_file: [false, nil]).collect { |e| e.update!(qty_on_hand: 0, present_in_file: false) }
  rescue Exception => e
    puts e.message
    UserMailer.with(user: e, script: "parts_authority_catalog").issue_in_script.deliver_now
  end
end