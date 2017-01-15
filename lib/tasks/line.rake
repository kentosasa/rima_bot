namespace :line do
  require 'line/bot'
  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  CHANNEL_TOKEN = ENV['LINE_CHANNEL_TOKEN']


  desc "通知時間を過ぎているが未通知のものを通知"
  task :notify => :environment do
    client = Line::Bot::Client.new { |config|
      config.channel_secret = CHANNEL_SECRET
      config.channel_token = CHANNEL_TOKEN
    }
    Remind.pending.each do |remind|
      response = remind.line_notify(client)
    end
  end
end
