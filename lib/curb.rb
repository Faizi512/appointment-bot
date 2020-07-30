module Curb
  def self.t14_inventory_api(ids, token)
    items = begin
      response = Curl.get("#{ENV['TURN14_STORE']}/v1/inventory/#{ids.join(',')}") do |http|
        http.headers['Authorization'] = "Bearer #{token}"
      end
      JSON.parse response.body_str
    end
  end

  def self.t14_auth_token
    token = begin
      response = Curl.post("#{ENV['TURN14_STORE']}/v1/token", "client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&grant_type=client_credentials")
      JSON.parse response.body_str
    end
  end

  def self.open_uri(url)
    retries = 0
    @open_uri ||= begin
      retries ||= 0
      open(url)
                  rescue StandardError => e
                    puts "Exception in opening file #{e}"
                    sleep 1
                    retry if (retries += 1) < 3
    end
  end
end
