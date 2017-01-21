class Ad
  BASE_URL = 'https://api.foursquare.com/v2/venues/'
  # BASE_PHOTO_URL = 'https://api.foursquare.com/v2/venues/VENUE_ID/photos'
  CLIENT_ID = 'B4S2UIB1SOX3WY5TMW1E3S1HGSSPUHJSPXKVU422NYMOGKYK'
  CLIENT_SECRET = 'ILVMKKHJLAI4JUEEZDMB4BX1WTRT0PDY5VIJFKQMZX1L5ZGB'

  def initialize(lat, lng)
    @lat = lat || 35.6586488
    @lng = lng || 139.6966408
    @item = {}
    venue_search
    venue_detail(@item[:id])
  end

  def column
    if @item.present?
      return {
        "thumbnailImageUrl": @item[:image],
        "title": @item[:name],
        "text": "待ち合わせ場所の近くの観光地「#{@item[:name]}」に行ってみるのはいかがですか？",
        "actions": [
          {
              "type": "uri",
              "label": "詳細を見る",
              "uri": "https://maps.google.com/maps?q=#{@item[:lat]},#{@item[:lng]}"
          },
          {
              "type": "uri",
              "label": "電話する",
              "uri": "tel:#{@item[:phoen]}"
          }
        ]
      }
    end
    nil
  end

  def venue_search
    url = URI.encode("#{BASE_URL}search?v=20161016&categoryId=4d4b7104d754a06370d81259&ll=#{@lat},#{@lng}&client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}")
    body = JSON.parse(open(url).read)
    res = body['response']['venues'][0]
    @item[:id] = res['id']
    @item[:name] = res['name'][0..20]
    @item[:phoen] = res['contact']['phone'] || 00000000000
    @item[:lat] = res['location']['lat']
    @item[:lng] = res['location']['lng']
  end

  def venue_detail(id)
    url = URI.encode("#{BASE_URL}#{id}?v=20161016&client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}")
    body = JSON.parse(open(url).read)
    res = body['response']['venue']['photos']['groups'][0]['items'][0]
    @item[:image] = res['prefix'] + "#{res['width']}x#{res['height']}" + res['suffix']
  end
end
