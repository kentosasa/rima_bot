# == Schema Information
#
# Table name: reminds
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  at         :datetime
#  activated  :boolean
#  reminded   :boolean
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
  belongs_to :group

  def new_actions
    [
      {
        "type": "postback",
        "label": "イベント作成",
        "data": "activate,#{self.id}"
      },
      {
        "type": "uri",
        "label": "編集して作成",
        "uri": "http://example.com/page/123"
      }
    ]
  end

  def activate!
    self.activated = true
    self.save
  end
end
