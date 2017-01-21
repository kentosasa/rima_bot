# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  user_type  :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  source_id  :string
#  uid        :string
#

class Group < ApplicationRecord
  has_many :reminds
  has_many :events
  has_many :schedules
  after_initialize :set_uid

  enum user_type: { user_id: 0, group_id: 1, room_id: 2 }

  def set_uid
    self.uid ||= SecureRandom.hex(32)
  end

  def self.find_or_create(event)
    case event['source']['type']
    when 'user'
      return Group.find_or_create_by(source_id: event['source']['userId'], user_type: :user_id)
    when 'group'
      return Group.find_or_create_by(source_id: event['source']['groupId'], user_type: :group_id)
    when 'room'
      return Group.find_or_create_by(source_id: event['source']['roomId'], user_type: :room_id)
    end
  end
end
