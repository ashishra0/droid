class WebhookService
  include HTTParty

  NOTION_URL = "https://api.notion.com/v1/pages"

  attr_reader :webhook_params, :webhook_text
  def initialize(webhook_params)
    @webhook_params = webhook_params
    @webhook_text = webhook_params["message"]["text"]
  end

  def process
    error_message if @webhook_params.blank?

    notion_params = {
      "parent": {
        "database_id": ENV["NOTION_DATABASE_ID"],
        "properties": {
          "Name": {
            "title": [
              {
                "text": {"content": webhook_text}
              }
            ]
          }
        }
      }
    }

    headers = {
      "Authorization": "Bearer #{ENV['NOTION_TOKEN']}",
      "Content-Type": "application/json",
      "Notion-Version": "2022-06-28"
    }

    response = HTTParty.post(NOTION_URL, body: notion_params.to_json, headers: headers)
    print response
    success_message
  end

  private

  def success_message
    {
      status: :success,
      message: "Webhook received"
    }
  end

  def error_message
    {
      status: :error,
      message: "Empty webhook params"
    }
  end
end
