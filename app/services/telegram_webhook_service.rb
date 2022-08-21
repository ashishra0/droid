class TelegramWebhookService
  include HTTParty

  TELEGRAM_URL = "https://api.telegram.org/bot#{ENV['TELEGRAM_TOKEN']}/sendMessage"

  attr_reader :webhook_params, :webhook_text, :webhook_chat_id, :webhook_message_id

  def initialize(webhook_params)
    @webhook_params = webhook_params
    @webhook_text = webhook_params["message"]["text"]
    @webhook_chat_id = webhook_params["message"]["chat"]["id"]
    @webhook_message_id = webhook_params["message"]["message_id"]
  end

  def process
    unless valid_url?(webhook_text)
      reply_back("Invalid message❌ \nPlease send Twitter URLs only 🙏")
      return
    end

    notion_params = {
      "parent": { "database_id": ENV["NOTION_DATABASE_ID"] },
      "properties": {
        "ID": { "title": [{ "text": { "content": webhook_message_id.to_s} }] },
        "Link": { "url": webhook_text }
      }
    }

    headers = {
      "Authorization": "Bearer #{ENV['NOTION_TOKEN']}",
      "Content-Type": "application/json",
      "Notion-Version": "2022-06-28"
    }

    response = HTTParty.post(ENV['NOTION_URL'], body: notion_params.to_json, headers: headers)

    if response.code == 200
      reply_back("Successfully added #{webhook_text} to Notion ✅")
      success_message
    else
      reply_back("Failed to add #{webhook_text} to Notion ❌ \nerror: #{response.body}")
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
    data = {
      chat_id: webhook_chat_id,
      message_id: webhook_message_id,
      text: text
    }

    HTTParty.post(TELEGRAM_URL, body: data.to_json, headers: headers)
  end

  def valid_url?(url)
    uri = URI.parse(url)

    uri.scheme == "https" && uri.host =~ /twitter\.com\Z/
  rescue URI::InvalidURIError
    false
  end
end
