# == Schema Information
#
# Table name: reminds
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  at         :datetime
#  activated  :boolean          default(FALSE)
#  reminded   :boolean          default(FALSE)
#  name       :string
#  body       :text
#  place      :string
#  datetime   :datetime
#  scale      :integer
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Remind < ApplicationRecord
  belongs_to :group
  scope :active, -> { where(activated: true) }
  scope :pending, -> { where('at <= ? AND activated = ? AND reminded = ?', DateTime.now, true, false) }

  def line_new_buttons_template
    {
      "type": "template",
      "altText": "ご使用の端末は対応していません",
      "template": {
        "type": "buttons",
        "thumbnailImageUrl": "#{ENV['ROOT_URL']}/crown.png",
        "title": self.name,
        "text": self.body,
        "actions": [
          {
            "type": "postback",
            "label": "イベント作成",
            "data": "activate,#{self.id}"
          },
          {
            "type": "uri",
            "label": "編集して作成",
            "uri": "http://example.com/page/123"
          }
        ]
      }
    }
  end

  def line_new_carousel_template
    {
      "type": "template",
      "altText": "ご使用の端末は対応しておりません",
      "template": {
        "type": "carousel",
        "columns": [
          {
            "thumbnailImageUrl": "#{ENV['ROOT_URL']}/crown.png",
            "title": "リマインド「#{self.name}」",
            "text": self.body,
            "actions": [
              {
                  "type": "uri",
                  "label": "詳細を見る",
                  "uri": "http://example.com/page/111"
              },
              {
                  "type": "postback",
                  "label": "30分後に再通知",
                  "data": "snooze,#{self.id}"
              }
            ]
          },
          {
            "thumbnailImageUrl": "https://tabelog.ssl.k-img.com/restaurant/images/Rvw/57427/640x640_rect_57427239.jpg",
            "title": "小料理店「松川」",
            "text": "食べログでトップ10に入る六本木で話題のお店です。日本が誇る和食はいかがですか？",
            "actions": [
              {
                  "type": "uri",
                  "label": "詳細を見る",
                  "uri": "http://example.com/page/222"
              },
              {
                  "type": "uri",
                  "label": "電話する",
                  "uri": "http://example.com/page/222"
              }
            ]
          }
        ]
      }
    }
  end

  def line_notify(client)
    if client.push_message(self.group.source_id, self.line_new_carousel_template)
      self.reminded = true
      self.save
    else
      return nil
    end
  end


  def activate!
    self.activated = true
    self.save
  end

  def snooze!
    self.at = self.at.since(30.minute)
    self.reminded = false
    self.save
  end
end
