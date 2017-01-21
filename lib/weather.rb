class Weather
  BASE_URL = 'http://api.openweathermap.org/data/2.5/forecast?'
  APPID = '4ccbd98ec12f496d7be738ed843f68e1'
  HOST = ENV['WEBHOOK_URL'].freeze

  def initialize(lat, lng, datetime)
    @date = datetime.to_date
    @lat, @lng = lat, lng
    @url = build_url(lat, lng)
  end

  def call
    return nil unless valid?
    html = open(@url).read
    body = JSON.parse(html)

    body["list"].each do |item|
      unix = item['dt']
      next unless @date.beginning_of_day.to_i < unix && unix < @date.end_of_day.to_i
      temp = item['main']['temp']
      image = image(item['weather'][0]['id'])
      return {temp: temp, image: image}
    end
    return {image: "#{HOST}/cal.png"}
  end

  def image(id)
    return '' if id.blank?
    case id
    when 0...600 then "#{HOST}/rain.png"
    when 600..700 then "#{HOST}/snow.png"
    when 700...800 then "#{HOST}/cal.png"
    when 800 then "#{HOST}/sunny.png"
    else "#{HOST}/crown.png"
    end
  end

  private
  def valid?
    @lat.present? && @lng.present?
  end

  def build_url(lat, lon, cnt=16)
    params = {
      APPID: APPID,
      lat: lat,
      lon: lon,
      cnt: cnt,
      units: 'metric'
    }
    url = BASE_URL + params.map{|k,v| "#{k}=#{v}"}.join('&')
    URI.encode(url)
  end

  def desctiption(id)
    {
      200 => '小雨と雷雨',
      201 => '雨と雷雨',
      202 => '大雨と雷雨',
      210 => '光雷雨',
      211 => '雷雨',
      212 => '重い雷雨',
      221 => 'ぼろぼろの雷雨',
      230 => '小雨と雷雨',
      231 => '霧雨と雷雨',
      232 => '重い霧雨と雷雨',
      300 => '光強度霧雨',
      301 => '霧雨',
      302 => '重い強度霧雨',
      310 => '光強度霧雨の雨',
      311 => '霧雨の雨',
      312 => '重い強度霧雨の雨',
      313 => 'にわかの雨と霧雨',
      314 => '重いにわかの雨と霧雨',
      321 => 'にわか霧雨',
      500 => '小雨',
      501 => '適度な雨',
      502 => '重い強度の雨',
      503 => '非常に激しい雨',
      504 => '極端な雨',
      511 => '雨氷',
      520 => '光強度のにわかの雨',
      521 => 'にわかの雨',
      522 => '重い強度にわかの雨',
      531 => '不規則なにわかの雨',
      600 => '小雪',
      601 => '雪',
      602 => '大雪',
      611 => 'みぞれ',
      612 => 'にわかみぞれ',
      615 => '光雨と雪',
      616 => '雨や雪',
      620 => '光のにわか雪',
      621 => 'にわか雪',
      622 => '重いにわか雪',
      701 => 'ミスト',
      711 => '煙',
      721 => 'ヘイズ',
      731 => '砂、ほこり旋回する',
      741 => '霧',
      751 => '砂',
      761 => 'ほこり',
      762 => '火山灰',
      771 => 'スコール',
      781 => '竜巻',
      800 => '晴天',
      801 => '薄い雲',
      802 => '雲',
      803 => '曇りがち',
      804 => '厚い雲'
    }[id]
  end
end
