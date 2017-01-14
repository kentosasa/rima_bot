# == Schema Information
#
# Table name: candidate_user_relations
#
#  id           :integer          not null, primary key
#  candidate_id :integer
#  user_id      :integer
#  attend       :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CandidateUserRelation < ApplicationRecord
  belongs_to :user
  belongs_to :candidate
end
