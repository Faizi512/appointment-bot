module Curb
  def self.request(url, token)
    response = Curl.get(url) do |http|
      http.headers['Authorization'] = "Bearer #{token}"
    end
    JSON.parse response.body_str
  end

  def self.request_token(url, parameters)
    response = Curl.post(url, parameters)
    JSON.parse response.body_str
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
