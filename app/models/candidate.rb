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

  def attend_percent
    point = 0.0
    count = 0
    self.candidate_user_relations.all.each do |cur|
      point += 1.0 if cur.good?
      point += 0.5 if cur.soso?
      point += 0.0 if cur.bad?
      count += 1
    end
    return '0' if count.zero?
    case (point * 100 / count).to_i
    when (60..100) then 'highlighted'
    else ''
    end
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
