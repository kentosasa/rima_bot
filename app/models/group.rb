# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  user_type  :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  character  :integer          default: 0
#  source_id  :string
#  uid        :string
#

class Group < ApplicationRecord
  HOST = ENV['WEBHOOK_URL'].freeze
  has_many :reminds
  has_many :events
  has_many :schedules
  after_initialize :set_uid

  enum user_type: { user_id: 0, group_id: 1, room_id: 2 }
  enum character: { siri: 0, male: 1, female: 2 }

  def set_uid
    self.uid ||= SecureRandom.hex(8)
  end

  def self.find_or_create(event)
    case event['source']['type']
    when 'user'
      Group.find_or_create_by(source_id: event['source']['userId'], user_type: :user_id)
    when 'group'
      Group.find_or_create_by(source_id: event['source']['groupId'], user_type: :group_id)
    when 'room'
      Group.find_or_create_by(source_id: event['source']['roomId'], user_type: :room_id)
    end
  end

  # "🤔⏱🤓👌🙆🙋☀️🌤⛅️🌥🌦☁️⛈🌩⚡️❄️🌨☃⛄️🌬💨🌪🌫☂☔️💧🕰📅📆🗓🔊🔇📢🔔🔕

  def create_event_text
    [
      'リマインド🔔を設定しますか?', # siri
      '通知🔔を設定しますか?', # male
      '通知🔔を設定しますか?'  # female
    ][self.character_before_type_cast]
  end

  def create_schedule_text
    [
      '日程調整をサポートしますか?', # siri
      '日程調整のお手伝いしようか?', # male
      '日程調整のお手伝いをしましょうか😆?'  # female
    ][self.character_before_type_cast]
  end

  def zero_plan_text
    [
      '本日以降に登録された予定はありませんでした。', # siri
      '今日以降に登録された予定はありませんでしたよ🤔', # male
      '今日以降に登録された予定はなかったよ!' # female
    ][self.character_before_type_cast]
  end

  def plan_exist_text
    [
      '本日以降の予定一覧です。', # siri
      '今日以降の予定だよ！',    # male
      '今日以降の予定ですよ！'   # female
    ][self.character_before_type_cast]
  end

  def line_notify_text
    [
      '予定の時間⏱が近づいてきました。', # siri
      '予定の時間⏱が近づいてきたよ！', # male
      '予定の時間⏱が近づいてきました！' # female
    ][self.character_before_type_cast]
  end

  def inactive_text
    [
      '🔕リマインド設定を取り消しました。', # siri
      '🔕通知を取り消ました。。',         # male
      '🔕通知を取り消しましたよ。'        # female
    ][self.character_before_type_cast]
  end

  def self_intro
    [
      [ # siri
        "リマインドBOTのリマさんだよ😆\n日程調整のサポートやリマインドは僕に任してね!😤",
        "会話からリマインドや日程調整のお手伝いをするよリマさんです😋\nよろしくね！",
        "「明日の8時に渋谷集合ね!」\nなどの会話があると、僕がサポートするよ🎶",
        "「日程調整」や「予定一覧」って言ってみると僕がフルサポートするよ👍"
      ],
      [ # male
        "リマインドBOTのリマさんだよ😆\n日程調整のサポートやリマインドは僕に任してね!😤",
        "会話からリマインドや日程調整のお手伝いをするよリマさんです😋\nよろしくね！",
        "「明日の8時に渋谷集合ね!」\nなどの会話があると、僕がサポートするよ🎶",
        "「日程調整」や「予定一覧」って言ってみると僕がフルサポートするよ👍"
      ],
      [ # female
        "リマインドBOTのリマさんだよ😆\n日程調整のサポートやリマインドは私に任してね!😤",
        "会話からリマインドや日程調整のお手伝いをするよリマさんです😋\nよろしくね！",
        "「明日の8時に渋谷集合ね!」\nなどの会話があると、私がサポートするよ🎶",
        "「日程調整」や「予定一覧」って言うと、私がフルサポートします🙋"
      ]
    ][self.character_before_type_cast].sample
  end

  def snooze_text(at)
    [
      "#{at.strftime('%-m月%-d日%-H時%M分')}に再通知しますね。", # siri
      "#{at.strftime('%-m月%-d日%-H時%M分')}に再通知するね！", # male
      "#{at.strftime('%-m月%-d日%-H時%M分')}に再通知しますね！"  # female
    ][self.character_before_type_cast]
  end

  def schedule_active_text(datetime)
    [
      "#{datetime.strftime('%-m月%-d日 %H:%M')}までに回答お願いします😃", # siri
      "#{datetime.strftime('%-m月%-d日 %H:%M')}までに回答お願いします😃", # male
      "#{datetime.strftime('%-m月%-d日 %H:%M')}までに回答お願いします😃"  # female
    ][self.character_before_type_cast]
  end

  def event_active_text(datetime, before)
    [
      "#{datetime.strftime('%-m月%-d日 %H:%M')}の#{before}前にリマインドを設定しました😃", # siri
      "#{datetime.strftime('%-m月%-d日 %H:%M')}の#{before}前に通知するね😃", # male
      "#{datetime.strftime('%-m月%-d日 %H:%M')}の#{before}前に通知しますね🙆"  # female
    ][self.character_before_type_cast]
  end

  def first_actions
    [{
      type: 'uri',
      label: '私の設定をする',
      uri: "#{HOST}/groups/#{self.uid}/edit"
    }]
  end

  def update_profile(json)
    self.name ||= json['displayName']
    # self.image ||= json['pictureUrl']
    # self.message ||= json['statusMessage']
    save
  end
end
