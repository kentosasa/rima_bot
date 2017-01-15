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

require 'test_helper'

class CandidateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
