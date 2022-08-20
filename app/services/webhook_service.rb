class WebhookService
  include HTTParty

  NOTION_URL = "https://api.notion.com/v1/pages"
  TELEGRAM_URL = "https://api.telegram.org/bot#{ENV['TELEGRAM_TOKEN']}/sendMessage"

  attr_reader :webhook_params, :webhook_text, :webhook_chat_id

  def initialize(webhook_params)
    @webhook_params = webhook_params
    @webhook_text = webhook_params["message"]["text"]
    @webhook_chat_id = webhook_params["message"]["chat"]["id"]
  end

  def process
    error_message if @webhook_params.blank?

    notion_params = {
      "parent": { "database_id": ENV["NOTION_DATABASE_ID"] },
      "properties": {
        "Name": { "title": [{ "text": { "content": webhook_text } }] },
        "URL": { "url": webhook_text }
      }
    }

    headers = {
      "Authorization": "Bearer #{ENV['NOTION_TOKEN']}",
      "Content-Type": "application/json",
      "Notion-Version": "2022-06-28"
    }

    response = HTTParty.post(NOTION_URL, body: notion_params.to_json, headers: headers)

    if response.code == 200
      reply_back("Successfully added #{webhook_text} to Notion ✅")
      success_message
    else
      reply_back("Failed to add #{webhook_text} to Notion ❌, error: #{response.body}")
      error_message
    end
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

  def reply_back(text)
    headers = { "Content-Type": "application/json" }
    data = { chat_id: webhook_chat_id, text: text }

    HTTParty.post(TELEGRAM_URL, body: data.to_json, headers: headers)
  end
end
