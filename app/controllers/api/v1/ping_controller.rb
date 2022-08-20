module Api
  module V1
    class PingController < ApplicationController
      def index
        render json: {
          message: 'pong',
          status: 'ok'
        }
      end
    end
  end
end
