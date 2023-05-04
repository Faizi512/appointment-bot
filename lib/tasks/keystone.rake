require 'openssl'
require 'net/ftp'
require 'socket'
desc 'To scrape keystone, ftp catalog'
class ImplicitFtp < Net::FTP
  FTP_PORT = 990
  def connect(host , port = FTP_PORT)
    synchronize do
      @host = host
      @bare_sock = open_socket(host, port)
      begin        
        ssl_sock = start_tls_session(Socket.tcp(host, port))          
        @sock = BufferedSSLSocket.new(ssl_sock, read_timeout: @read_timeout)
        voidresp
        if @private_data_connection
          voidcmd("PBSZ 0")
          voidcmd("PROT P")
        end
      rescue OpenSSL::SSL::SSLError, Net::OpenTimeout
        @sock.close
        raise
      end
    end
  end
end

task keystone: :environment do
  ca_file = File.read("#{Rails.root}/ca.crt")

  options = {
      ssl: {
        :min_version => OpenSSL::SSL::TLS1_VERSION,
        :verify_mode => OpenSSL::SSL::VERIFY_NONE,
        :verify_hostname => false,
        :ca_file => ca_file
        },
      port: 990,        
      implicit_ftps:true,
      username: "S138912",
      password: "mei89dsc",
      debug_mode: true,   
  }

  ImplicitFtp.open("ftp.ekeystone.com", options) do |ftp|
    ftp.getbinaryfile('inventory.zip', 'zip_inventory', 1024)
    Zip::File.open('zip_parts_authority') do |zip_file|
        raise Exception.new "Date not found" if !zip_file.present?
        zip_file.each do |entry|
          puts "Unzip #{entry.name}"
          content = entry.get_input_stream.read
          CSV.parse(content, headers: true, header_converters: :symbol) do |row|
            puts row.inspect
            row = row.to_s.split(",")
            row_line = row[0]
            part_number = row[1]
            price = row[2]
            core_price = row[3]
            qty = row[4]
            packs = row[5]
            brand = row[6]

            # product = KeystoneProduct.find_or_create_by(part_number: part_number)
            # product.update()
          end
        end
    end
  end
end