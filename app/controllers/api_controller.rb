class ApiController < ApplicationController
  def notify
    now = DateTime.now
    reminds = Remind.active.where("at <= ?", now)
    reminds.each do |remind|
      p remind
      if remind.line_notify
        puts "#{remind.id}を通知しました。"
      else
        puts "#{remind.id}の通知に失敗"
      end
    end
    render :text => "Notify", :status => 200
  end
end