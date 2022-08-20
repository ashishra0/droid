class WebhookService

  def initialize(webhook_params)
    @webhook_params = webhook_params
  end

  def process
    if @webhook_params.nil?
      {
        status: :error,
        message: "Webhook params are missing"
      }
    end

    {
      status: :success,
      message: "Webhook received"
    }
  end
end