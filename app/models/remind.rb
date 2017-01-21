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
#  latitude   :float
#  longitude  :float
#  address    :string
#  uid        :string
#

class Remind < ApplicationRecord
  HOST = ENV['WEBHOOK_URL'].freeze
  after_initialize :set_uid

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
  scope :between, ->(from, to) {
    if from.present? && to.present?
      where(datetime: from..to)
    elsif from.present?
      where('datetime >= ?', from)
    elsif to.present?
      where('datetime <= ?', to)
    end
  }

  attr_accessor :date, :time, :before, :remind_type, :candidate_body

  def set_uid
    self.uid ||= SecureRandom.hex(32)
  end

  def show_url
    "#{HOST}/reminds/#{self.uid}"
  end

  def answer_url
    "#{HOST}/schedules/#{self.uid}/answer"
  end

  def edit_url
    "#{HOST}/reminds/#{self.uid}/edit"
  end

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
      label: '編集して設定',
      uri: self.edit_url
    }]
  end

  # active=trueにした時のテキスト
  def active_text
    if self.schedule?
      #"😎🔔☀️📝🌜😃🌙👀"
      "#{self.datetime.strftime('%-m月%-d日 %H:%M')}までに回答お願いします😃"
    elsif self.event?
      "#{self.datetime.strftime('%-m月%-d日 %H:%M')}の#{self.before}前にリマインドを設定しました😃"
    end
  end

  # active=trueにした時に返すactions
  def active_actions
    actions = []
    actions.push({
      type: 'uri',
      label: '👀 詳細を見る',
      uri: self.show_url
    })
    if self.schedule?
      actions.push({
        type: 'uri',
        label: '📝 回答する',
        uri: self.answer_url
      })
    end
    actions.push({
      type: 'postback',
      label: '🔕 通知を取り消す',
      data: "action=inactivate&remind_id=#{id}"
    })
    actions
  end

  # 詳細情報返すactions
  def show_actions
    [{
      type: 'uri',
      label: '詳細を見る',
      uri: self.show_url
    }, {
      type: 'uri',
      label: '編集する',
      uri: self.edit_url
    }]
  end

  def show_column
    {
      "thumbnailImageUrl": "#{self.weather[:image]}",
      "title": "リマインド「#{self.name}」",
      "text": self.body,
      "actions": self.show_actions
    }
  end

  def emoji
    str = "\n"
    str += "📆 #{self.datetime.strftime("%-m月%-d日")} "
    str += "🔉 #{self.before}前"
    str += "🗺#{self.place}" if self.place
    str
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
          uri: self.show_url
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

  def weather
    weather = Weather.new(latitude, longitude, datetime)
    weather.call
  end
end
