class Weather
  WEATHER_API_BASE_URL = 'http://api.openweathermap.org/data/2.5/forecast?APPID=4ccbd98ec12f496d7be738ed843f68e1&'
  HOST = ENV['WEBHOOK_URL'].freeze

  def initialize(lat, lng, datetime)
    @date = datetime.to_date
    @endpoint = URI.encode(WEATHER_API_BASE_URL + "lat=#{lat}&lon=#{lng}&cnt=16")
    if (@date - DateTime.now.to_date).to_i < 16 && lat && lng
      call_api
    end
  end

  def image
    case @forecast
    when '雨'
      return "#{HOST}/rain.png"
    when '雪'
      return "#{HOST}/snow.png"
    when '晴れ'
      return "#{HOST}/sunny.png"
    when '曇り'
      return "#{HOST}/crown.png"
    end
    return "#{HOST}/cal.png"
  end

  def temp
    @temp
  end

  def forecast
    @forecast
  end

  private
  def call_api
    body = JSON.parse(open(@endpoint).read)
    body["list"].each do |item|
      next unless Date.parse(item["dt_txt"]) == @date
      @temp = item["main"]["temp"]-273
      @forecast = forecast_by_api_id(item['weather'][0]['id'])
    end
    nil
  end

  def forecast_by_api_id(id)
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
