# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  comment    :string
#  schedule_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ApplicationRecord
  belongs_to :schedule
end
