desc 'To scrape turn14 price through api call'
task export_t14_price: :environment do
  token = Curb.t14_auth_token['access_token']
  price_url = "#{ENV['TURN14_STORE']}/v1/pricing?page=1"
  retries = 0
  loop do
    all_price = Curb.make_get_request(price_url, token)
    puts "Page_URL: #{price_url}"
    all_price['data'].each_with_index do |item, index|
      next if item['attributes']['pricelists'].blank?

      product = Turn14Product.find_by(id: item['id'])
      next if product.blank?

      if item['attributes']['pricelists'].find { |x| x['name'] == 'MAP' }.present?
        @price = item['attributes']['pricelists'].find { |x| x['name'] == 'MAP' }['price']
      elsif item['attributes']['pricelists'].find { |x| x['name'] == 'Retail' }.present?
        @price = item['attributes']['pricelists'].find { |x| x['name'] == 'Retail' }['price']
      end

      product.update(price: @price)
      puts "Count: #{index}"
    end

    exit if all_price['links']['next'].nil?

    price_url = ENV['TURN14_STORE'] + all_price['links']['next']
  rescue StandardError => e
    puts "exception #{e}"
    sleep 1
    token = Curb.t14_auth_token['access_token']
    exit if (retries += 1) < 2
  end
end
