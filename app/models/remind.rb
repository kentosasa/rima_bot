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
#  hash       :string           index
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
      label: '編集して作成',
      uri: self.edit_url
    }]
  end

  # 通知を有効化した時に返すactions
  def active_actions
    [{
      type: 'uri',
      label: '詳細',
      uri: self.show_url
    }, {
      type: 'postback',
      label: '取り消す',
      data: "action=inactivate&remind_id=#{id}"
    }]
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
      "thumbnailImageUrl": "#{self.weather_img}",
      "title": "リマインド「#{self.name}」",
      "text": self.body,
      "actions": self.show_actions
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

  def weather_img
    weather = Weather.new(self.latitude, self.longitude, self.datetime)
    weather.image
  end
end
