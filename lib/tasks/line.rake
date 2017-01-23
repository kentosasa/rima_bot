namespace :line do
  require 'line/bot'
  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  CHANNEL_TOKEN = ENV['LINE_CHANNEL_TOKEN']

  desc '通知時間を過ぎているが未通知のものを通知'
  # 未通知のものを通知
  # 人数が揃っていないスケジュールの通知
  task :notify => :environment do
    @reminds = Remind.active.pending.before_and_after(2000)
    @reminds.each do |remind|
      if remind.line_notify(client)
        puts "#{remind.id}を通知しました。"
        p remind
      else
        puts "失敗"
      end
    end
  end

  desc '意図しないで作られた無駄な通知を削除する'
  task :delete_remind => :environment do
    # 作成状態で昨日以降に作られたリマインド一覧
    @reminds = Remind.created.between(nil, Time.zone.now - 1)
    @reminds.delete_all
  end

  private
  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = CHANNEL_SECRET
      config.channel_token = CHANNEL_TOKEN
    end
  end
end
