# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  user_type  :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  source_id  :string
#  uid        :string
#

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
