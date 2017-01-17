module RemindsHelper

  def google_cal_link(remind)
    url = 'http://www.google.com/calendar/event?'
    url += 'action=TEMPLATE'
    url += '&text=' + remind.name
    url += '&details=' + remind.body if remind.body.present?
    url += '&date=' + remind.datetime.strftime("%Y%m%dT%H%m%SZ")
    url += '&location=' + remind.address if remind.address.present?
    url += '&trp=false'
    url += '&sprop=リマさん'
    #url += '&sprop=' + # ここのリマインドの詳細リンク
    url
  end
end
