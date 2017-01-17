# == Schema Information
#
# Table name: reminds
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  at         :datetime
#  activated  :boolean          default(FALSE)
#  reminded   :boolean          default(FALSE)
#  name       :string
#  body       :text
#  place      :string
#  datetime   :datetime
#  scale      :integer
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Remind < ApplicationRecord
  HOST = ENV['WEBHOOK_URL'].freeze

  belongs_to :group
  scope :active, -> { where(activated: true) }  # 通知有効化されているリマインド
  scope :pending, -> { where(reminded: false) } # 未通知のリマインド
  scope :before_and_after, -> (min) {           # 現在時刻から前後min分のリマインド
    return if min.blank?
    now = DateTime.now
    before = now - Rational(min, 24 * 60)
    after = now + Rational(min, 24 * 60)
    where(at: before..after).order(at: :asc)
  }
  #scope :pending, -> { where('at <= ? AND activated = ? AND reminded = ?', DateTime.now, true, false) }

  attr_accessor :date, :time, :before, :remind_type, :candidate_body

  def parse_datetime
    [self.datetime.to_s(:date), self.datetime.to_s(:time)]
  end

  def before
    return 60 if datetime.nil?
    min = (datetime - at).to_i / 60
    if min < 60
      "#{min}分"
    elsif min < 60 * 24
      hour = min / 60
      "#{hour}時間"
    else
      day = min / (60 * 24)
      hour = min - (60 * 24 * day)
      "#{day}日"
    end
  end

  # 日付を含んだ時に返すactions
  def create_actions
    [{
      type: 'postback',
      label: datetime.to_s(:without_year) + 'で設定',
      data: "action=activate&remind_id=#{id}"
    }, {
      type: 'uri',
      label: '編集して作成',
      uri: "#{HOST}/reminds/#{id}/edit"
    }]
  end

  # 通知を有効化した時に返すactions
  def active_actions
    [{
      type: 'uri',
      label: '詳細',
      uri: "#{HOST}/reminds/#{id}"
    }, {
      type: 'postback',
      label: '取り消す',
      data: "action=inactivate&remind_id=#{id}"
    }]
  end

  # 通知を無効化した時に返すactions
  def inactiva_actions
    [{
      type: 'uri',
      label: '詳細を見る',
      uri: "#{HOST}/reminds/#{id}"
    }, {
      type: 'uri',
      label: '編集する',
      uri: "#{HOST}/reminds/#{id}/edit"
    }]
  end

  def line_new_carousel_template
    {
      "type": "template",
      "altText": "ご使用の端末は対応しておりません",
      "template": {
        "type": "carousel",
        "columns": [
          {
            "thumbnailImageUrl": "#{self.weather_img}",
            "title": "リマインド「#{self.name}」",
            "text": self.body,
            "actions": [
              {
                  "type": "uri",
                  "label": "詳細を見る",
                  "uri": "http://example.com/page/111"
              },
              {
                  "type": "postback",
                  "label": "30分後に再通知",
                  "data": "snooze,#{self.id}"
              }
            ]
          },
          {
            "thumbnailImageUrl": "https://tabelog.ssl.k-img.com/restaurant/images/Rvw/57427/640x640_rect_57427239.jpg",
            "title": "小料理店「松川」",
            "text": "食べログでトップ10に入る六本木で話題のお店です。日本が誇る和食はいかがですか？",
            "actions": [
              {
                  "type": "uri",
                  "label": "詳細を見る",
                  "uri": "http://example.com/page/222"
              },
              {
                  "type": "uri",
                  "label": "電話する",
                  "uri": "http://example.com/page/222"
              }
            ]
          }
        ]
      }
    }
  end

  def line_notify(client)
    response = client.push_message(self.group.source_id, {
      type: 'template',
      altText: "#{self.before}後に[#{self.name}]があります。",
      template: {
        type: 'buttons',
        title: "#{self.before}後に[#{self.name}]",
        text: self.body || '',
        actions: [{
          type: 'uri',
          label: '詳細を見る',
          uri: "#{HOST}/reminds/#{id}"
        }, {
          type: 'postback',
          label: '10分後に再通知',
          data: "action=snooze&remind_id=#{id}"
        }]
      }
    })
    if response.is_a? Net::HTTPSuccess
      return self.reminded!
    end
    false
  end

  def event?
    self.type == 'Event'
  end

  def schedule?
    self.type == 'Schedule'
  end

  def activate!
    self.activated = true
    self.save
  end

  def inactivate!
    self.activated = false
    self.save
  end

  def reminded!
    self.reminded = true
    self.save
  end

  def snooze!(min = 30)
    self.at = self.at.since(min.minute)
    self.reminded = false
    self.save
  end

  def weather_img
    # APIで取得できる天気予報が15日後までなため
    if (self.datetime.to_date-DateTime.now.to_date).to_i < 16
      weather = Weather.find_or_create_by(place: self.place, date: self.datetime.to_date)
      return weather.find_or_create_image
    end
    return "#{ENV['ROOT_URL']}/crown.png"
  end
end
