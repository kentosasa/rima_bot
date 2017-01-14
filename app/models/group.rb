# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  user_type  :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Group < ApplicationRecord
  has_many :reminds
  has_many :events
  has_many :schedules

  def self.find_by_event(event)
    case event['source']['type']
    when 'user'
      return Group.find_or_create_by(source_id: event['source']['userId'], user_type: 0)
    when 'group'
      return Group.find_or_create_by(source_id: event['source']['groupId'], user_type: 1)
    when 'room'
      return Group.find_or_create_by(source_id: event['source']['roomId'], user_type: 2)
    end
  end
end
