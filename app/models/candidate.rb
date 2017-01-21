# == Schema Information
#
# Table name: candidates
#
#  id          :integer          not null, primary key
#  schedule_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  title       :string
#

class Candidate < ApplicationRecord
  has_many :candidate_user_relations
  has_many :users, through: :candidate_user_relations, source: :user
  #has_many :answers, class_name: 'CandidateUserRelation'

  #has_many :users, :through => :candidate_user_relations
  def good?(user)
    relation(user).good?
  end

  def soso?(user)
    relation(user).soso?
  end

  def bad?(user)
    relation(user).bad?
  end

  def attend_users
    ids = self.candidate_user_relations.where(attend: true).pluck(:user_id)
    users = User.where(id: ids)
  end

  def absent_users
    ids = self.candidate_user_relations.where(attend: false).pluck(:user_id)
    users = User.where(id: ids)
  end

  private
  def relation(user)
    CandidateUserRelation.find_by(candidate_id: self.id, user_id: user.id)
  end
end
