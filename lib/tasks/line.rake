namespace :line do
  require 'line/bot'
  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  CHANNEL_TOKEN = ENV['LINE_CHANNEL_TOKEN']

  desc '通知時間を過ぎているが未通知のものを通知'
  # 未通知のものを通知
  # 人数が揃っていないスケジュールの通知
  task :notify => :environment do
    @reminds = Remind.active.pending.before_and_after(20)
    @reminds.each do |remind|
      p hoge
      if remind.line_notify(client)
        puts "#{remind.id}を通知しました。"
        p remind
      else
        puts "失敗"
      end
    end
  end

  private
  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = CHANNEL_SECRET
      config.channel_token = CHANNEL_TOKEN
    end
  end
end
