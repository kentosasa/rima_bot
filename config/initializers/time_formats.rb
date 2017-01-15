Time::DATE_FORMATS[:default] = '%Y/%m/%d %H:%M'
Time::DATE_FORMATS[:datetime] = '%Y/%m/%d %H:%M'
Time::DATE_FORMATS[:date] = '%Y/%m/%d'
Time::DATE_FORMATS[:time] = '%H:%M'
Date::DATE_FORMATS[:default] = '%Y/%m/%d'
Time::DATE_FORMATS[:human] = lambda {|date|
  seconds = (Time.now - date).round;
  days    = seconds / (60 * 60 * 24); return "#{date.month}月#{date.day}日" if days > 0;
  hours   = seconds / (60 * 60);      return "#{hours}時間前" if hours > 0;
  minutes = seconds / 60;             return "#{minutes}分前" if minutes > 0;
  return "#{seconds}秒前"
}
