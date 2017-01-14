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

require 'test_helper'

class CandidateUserRelationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
