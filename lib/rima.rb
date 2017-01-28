require 'line/bot'
module Rima
  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  CHANNEL_TOKEN = ENV['LINE_CHANNEL_TOKEN']

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = CHANNEL_SECRET
      config.channel_token = CHANNEL_TOKEN
    end
  end
end
