class TelegramWebhookService
  include HTTParty
  include ActiveModel::Validations

  TELEGRAM_URL = "https://api.telegram.org/bot#{ENV['TELEGRAM_TOKEN']}/sendMessage"

  attr_reader :webhook_params, :webhook_text, :webhook_chat_id, :webhook_message_id

  def initialize(webhook_params)
    @webhook_params = webhook_params
    @webhook_text = webhook_params["message"]["text"]
    @webhook_chat_id = webhook_params["message"]["chat"]["id"]
    @webhook_message_id = webhook_params["message"]["message_id"]
  end

  def process
    if webhook_params.blank? || valid_url?
      reply_back("Invalid message❌. \n Please send Twitter URLs only.")
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

  def valid_url?
    uri = URI.parse(webhook_text)

    uri.scheme == "https" && uri.host =~ /twitter\.com\Z/
  rescue URI::InvalidURIError
    false
  end
end
