# frozen_string_literal: true
redis_config = Rails.application.config_for(:redis)

HOST_REDIS_INSTANCE = Redis.new(
  host: redis_config["host"],
  port: redis_config["port"],
  db: redis_config["db"]
)
