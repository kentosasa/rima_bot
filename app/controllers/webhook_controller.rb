require "#{Rails.root}/lib/line_client"
require 'line/bot'

class WebhookController < ApplicationController
  protect_from_forgery with: :null_session

  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  CHANNEL_TOKEN = ENV['LINE_CHANNEL_TOKEN']

  def callback
    signature = request.env["HTTP_X_LINE_SIGNATURE"]
    body = request.body.read
    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end
    events = client.parse_events_from(body)
    events.each do |event|
      c = LineClient.new(client, event)
      c.reply
    end
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = CHANNEL_SECRET
      config.channel_token = CHANNEL_TOKEN
    end
  end
end
