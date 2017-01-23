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

class Schedule < Remind
  belongs_to :group
  has_many :candidates
end
