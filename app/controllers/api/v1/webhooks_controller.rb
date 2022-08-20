module Api
  module V1
    class WebhooksController < ApplicationController

      def receive
        result = TelegramWebhookService.new(webhook_params).process

        render json: result, status: :ok
      end

      private

      def webhook_params
        params.require(:webhook).permit!
      end
    end
  end
end
