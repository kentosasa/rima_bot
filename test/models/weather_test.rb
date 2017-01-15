# == Schema Information
#
# Table name: weathers
#
#  id         :integer          not null, primary key
#  place      :string
#  image      :string
#  forcast    :string
#  temp       :string
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class WeatherTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
