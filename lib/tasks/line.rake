namespace :line do
  desc '通知時間を過ぎているが未通知のものを通知'
  # 未通知のものを通知
  # 人数が揃っていないスケジュールの通知
  task :notify => :environment do
    #reminds = Remind.active.before_and_after(60)
    #now = Time.zone.now.in_time_zone('Tokyo')
    now = DateTime.now
    p now
    after = now.since(10.minute)
    reminds = Remind.active.where("at <= ?", after)

    reminds.each do |remind|
      p remind
      if remind.line_notify
        puts "#{remind.id}を通知しました。"
      else
        puts "#{remind.id}の通知に失敗"
      end
    end
  end

  desc '意図しないで作られた無駄な通知を削除する'
  task :delete_remind => :environment do
    # 作成状態で昨日以降に作られたリマインド一覧
    now = Time.zone.now.in_time_zone('Tokyo')
    @reminds = Remind.created.between(nil, now - 1)
    @reminds.delete_all
  end
end
