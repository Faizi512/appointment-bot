task manufacturer_and_purchase_order: :environment do
  token = Curb.t14_auth_token['access_token']
  Turn14Product.find_in_batches(batch_size: 250) do |item_batch|
    item_ids = item_batch.pluck('item_id')
    t14_items = Curb.t14_inventory_api(item_ids, token)
    raise 'Invalid_token. Get new one.' if t14_items.dig('error') == 'invalid_token'

    t14_items['data'].each do |item|
      item_hash = item['attributes']
      product = Turn14Product.find_by(item_id: item['id'])
      stock = item_hash.dig('manufacturer', 'stock')
      esd = item_hash.dig('manufacturer', 'esd')
      add_manufacturer(product, stock, esd) if stock.present? && esd.present?
      add_purchase_order(product, item_hash['eta']) if item_hash['eta'].present?
    end
  rescue StandardError => e
    puts "exception #{e}"
    sleep 1
    token = Curb.t14_auth_token['access_token']
    retry
  end
end

def add_manufacturer(product, stock, esd)
  product.add_manufacturer(product, stock, esd)
end

def add_purchase_order(product, eta)
  product.add_latest_purchase_order(product, eta)
  product.add_archived_purchase_order(product, eta)
end
