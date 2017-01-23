# == Schema Information
#
# Table name: reminds
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  at         :datetime
#  status     :integer          default(CREATED)
#  name       :string
#  body       :text
#  place      :string
#  datetime   :datetime
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  latitude   :float
#  longitude  :float
#  address    :string
#  uid        :string
#

class Remind < ApplicationRecord
  include Rima
  HOST = ENV['WEBHOOK_URL'].freeze
  after_initialize :set_uid

  enum status: [:created, :activated, :notified]
  attr_accessor :date, :time, :before, :remind_type, :candidate_body

  belongs_to :group
  scope :created, -> { where(status: :created) }  # 作成されただけのリマインド
  scope :pending, -> { where(status: :notified) } # 通知有効化されているリマインド
  scope :active, -> { where(status: :activated) } # 未通知のリマインド
  scope :before_and_after, -> (min) {           # 現在時刻から前後min分のリマインド
    return if min.blank?
    now = Time.zone.now
    before = now.ago(min.minute)
    after = now.since(min.minute)
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

  # スケジュール作成のactions
  def schedule_actions
    [{
      type: 'uri',
      label: '候補日を選んで作成する',
      uri: edit_url
    }]
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
    actions = [{
      type: 'uri',
      label: '👀 詳細を見る',
      uri: self.show_url
    }]
    if self.schedule?
      actions.push({
        type: 'uri',
        label: '📝 回答する',
        uri: self.answer_url
      })
    else
      actions.push({
        type: 'postback',
        label: '🔕 通知を取り消す',
        data: "action=inactivate&remind_id=#{id}"
      })
    end
    actions
  end

  def show_column
    {
      thumbnailImageUrl: self.weather[:image],
      title: self.name,
      text: self.body + self.emoji,
      actions: self.active_actions
    }
  end

  def emoji
    str = "\n"
    str += "📆 #{self.datetime.strftime("%-m月%-d日")} "
    str += "🔉 #{self.before}前"
    #str += "🗺#{self.place}" if self.place
    str
  end

  def notify_columns
    [
      {
        thumbnailImageUrl: "#{self.weather[:image]}",
        title: "リマインド「#{self.name}」",
        text: self.body,
        actions: [{
          type: 'uri',
          label: '詳細を見る',
          uri: self.show_url
        }, {
          type: 'postback',
          label: '10分後に再通知',
          data: "action=snooze&remind_id=#{id}"
        }]
        }, {
          thumbnailImageUrl: "#{HOST}/ad1.jpg",
          title: "鳥貴族",
          text: '安くて美味しい鳥貴族は二次会にいかがですか？',
          actions: [
            {
              type: 'uri',
              label: '詳細を見る',
              uri: 'https://www.torikizoku.co.jp/shops/detail/337'
            }, {
              type: 'uri',
              label: '電話する',
              uri: 'tel:0364169177'
            }
          ]
        }, {
          thumbnailImageUrl: "#{HOST}/ad2.jpg",
          title: "ダーツ・バー Bee",
          text: '朝5時まで遊べる渋谷のお店です。おしゃれなダーツバーで夜をすごしませんか？',
          actions: [
            {
              type: 'uri',
              label: '詳細を見る',
              uri: 'https://www.hotpepper.jp/strJ000013646/'
            }, {
              type: 'uri',
              label: '電話する',
              uri: 'tel:0364169177'
            }
          ]
        }, {
          thumbnailImageUrl: "#{HOST}/ad3.jpg",
          title: "ダーツ・バー Bee",
          text: 'ご飯を食べた後は夜通しダンスをして刺激的な夜を過ごしませんか？',
          actions: [
            {
              type: 'uri',
              label: '詳細を見る',
              uri: 'http://t2-shibuya.com/club/'
            }, {
              type: 'uri',
              label: '電話する',
              uri: 'tel:0364169177'
            }
          ]
        }
    ]
  end

  def line_notify
    actions = [{
      type: 'uri',
      label: '詳細を見る',
      uri: self.show_url
    }, {
      type: 'postback',
      label: '10分後に再通知',
      data: "action=snooze&remind_id=#{id}"
    }]
    message = Rima::Message.new(self.group, nil)
    message.push_message('予定の時間が近づいてきました😃')
    response = message.push_buttons('', self.body + self.emoji, actions)
    # message.push_message("予定の時間が近づいてきました。\n ついでにこんな場所はいかがですか？")
    if response.is_a? Net::HTTPSuccess
      return self.notified!
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
    return nil if self.activated?
    if self.activated!
      return [self.name, self.active_text, self.active_actions]
    else
      return nil
    end
  end

  def inactivate!
    return nil if self.created?
    if self.created!
      "🔕リマインド設定を取り消しました。"
    else
      nil
    end
  end

  def snooze!(min = 30)
    if self.update(at: self.at.since(min.minute), status: :activated)
      "#{self.at.strftime("%-m月%-d日%-H時%M分")}に再通知します!"
    else
      nil
    end
  end

  def weather
    weather = Weather.new(latitude, longitude, datetime)
    weather.call
  end
end
