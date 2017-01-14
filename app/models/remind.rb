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

  def default_actions
    [
      {
        "type": "uri",
        "label": "8:00に追加",
        "uri": "http://example.com/page/123"
      },
      {
        "type": "uri",
        "label": "編集して作成",
        "uri": "http://example.com/page/123"
      }
    ]
  end
end
