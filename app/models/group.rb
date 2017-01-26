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

  def create_event_text
    [
      'リマインド🔔を設定しますか?', # siri
      'リマインド🔔を設定するかい?', # male
      'リマインド🔔を設定しますか><?'  # female
    ][self.character_before_type_cast]
  end

  def create_schedule_text
    [
      '日程調整をサポートしますか?', # siri
      '日程調整をサポートしようか?', # male
      '日程調整をサポートしましょうか😆?'  # female
    ][self.character_before_type_cast]
  end

  def zero_plan_text
    [
      '今日以降の登録された予定はなかったよ。', # siri
      '今日以降の登録された予定はなかったよ。', # male
      '今日以降の登録された予定はなかったよ。'
    ][self.character_before_type_cast]
  end

  def plan_exist_text
    [
      '今日以降の予定ですよ！', # siri
      '今日以降の予定ですよ！', # male
      '今日以降の予定ですよ！'
    ][self.character_before_type_cast]
  end

  def self_intro
    [
      "リマインドBOTのリマさんだよ😆\n日程調整のサポートやリマインドは僕に任してね!😤",
      "会話からリマインドや日程調整のお手伝いをするよリマさんです😋\nよろしくね！",
      "「明日の8時に渋谷集合ね!」\nなどの会話があると、僕がサポートするよ🎶",
      "「日程調整」や「予定一覧」って言ってみると僕がフルサポートするよ👍"
    ].sample
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
