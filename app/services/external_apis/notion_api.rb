module ExternalApis
  class NotionApi
    include HTTParty
    read_timeout 5

    attr_reader :headers

    def initialize
      @headers = {
        "Authorization": "Bearer #{ENV['NOTION_TOKEN']}",
        "Content-Type": "application/json",
        "Notion-Version": "2022-06-28"
      }
    end

    def publish(body)
      self.class.post(ENV['NOTION_URL'], body:body.to_json, headers: headers)
    end
  end
end
