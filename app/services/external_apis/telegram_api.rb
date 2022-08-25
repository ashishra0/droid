module ExternalApis
  class TelegramApi
    include HTTParty
    TELEGRAM_URL = "https://api.telegram.org/bot#{ENV['TELEGRAM_TOKEN']}/sendMessage"
    read_timeout 5

    attr_reader :headers

    def initialize
      @headers = { "Content-Type": "application/json" }
    end

    def publish(body)
      self.class.post(TELEGRAM_URL, body: body.to_json, headers: headers)
    end
  end
end
