# == Schema Information
#
# Table name: candidates
#
#  id          :integer          not null, primary key
#  date        :datetime
#  schedule_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Candidate < ApplicationRecord
  has_many :candidate_user_relations
  has_many :users, :through => :candidate_user_relations
end
