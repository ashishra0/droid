class TelegramWebhookService

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

    response = ExternalApis::NotionApi.new.publish(notion_params)

    if response.code == 200
      reply_back("Successfully published to Notion ✅")
      success_message
    else
      reply_back("Failed to publish to Notion ❌ \nerror: #{response.body}")
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

  def valid_url?(url)
    uri = URI.parse(url)

    uri.scheme == "https" && uri.host =~ /twitter\.com\Z/
  rescue URI::InvalidURIError
    false
  end

  def reply_back(text)
    data = {
      chat_id: webhook_chat_id,
      reply_to_message_id: webhook_message_id,
      text: text
    }

    ExternalApis::TelegramApi.new.publish(data)
  end

  def notion_params
    {
      "parent": { "database_id": ENV["NOTION_DATABASE_ID"] },
      "properties": {
        "ID": { "title": [{ "text": { "content": webhook_message_id.to_s} }] },
        "Link": { "url": webhook_text }
      }
    }
  end
end
