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

class Weather < ApplicationRecord
  OPEN_WEATHER_BASE_URL = 'http://api.openweathermap.org/data/2.5/forecast?APPID=4ccbd98ec12f496d7be738ed843f68e1&'

  def find_or_create_image
    return self.image if self.image.present?
    place = self.place || 'Tokyo'
    url = URI.encode(OPEN_WEATHER_BASE_URL + "q=#{place},jp&cnt=16")
    res = JSON.parse(open(url).read)

    res["list"].each do |item|
      next unless Date.parse(item["dt_txt"]) == self.date
      self.temp = (item["main"]["temp"]-273).to_i
      self.forcast = weather_by_id(item['weather'][0]['id'].to_i)
      case self.forcast
      when '雨'
        self.image = "#{ENV['ROOT_URL']}/rain.png"
      when '雪'
        self.image = "#{ENV['ROOT_URL']}/snow.png"
      when '晴れ'
        self.image = "#{ENV['ROOT_URL']}/sunny.png"
      when '曇り'
        self.image = "#{ENV['ROOT_URL']}/crown.png"
      end
      self.save
      return self.image
    end
    "#{ENV['ROOT_URL']}/crown.png"
  end

  private
  def weather_by_id(id)
    if id < 600
      return '雨'
    elsif id < 700
      return '雪'
    elsif id == 800
      return '晴れ'
    else
      return '曇り'
    end
  end
end
