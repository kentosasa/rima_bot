class LineClient
  MESSAGE_TYPE_TO_METHOD_MAP = {
    'text' => :receive_text,
    'image' => :echo_image,
    'video' => :echo_video,
    'audio' => :echo_audio,
    'location' => :echo_location,
    'sticker' => :echo_sticker
  }.freeze
  HOST = ENV['WEBHOOK_URL'].freeze

  def initialize(client, event)
    @client = client
    @event = event
    @message_target = find_or_create_message_target(@event)
  end

  def reply
    case @event
    when Line::Bot::Event::Message
      send(MESSAGE_TYPE_TO_METHOD_MAP[@event.type.to_s], @event)
    when Line::Bot::Event::Follow
      receive_follow
    when Line::Bot::Event::Unfollow
      receive_unfollow
    when Line::Bot::Event::Join
      receive_join
    when Line::Bot::Event::Leave
      receive_leave
    when Line::Bot::Event::Postback
      receive_postback(@event)
    end
  end

  private

  def find_or_create_message_target(event)
    case event['type']
    when 'user'
      #@user = User.find_or_create_by(mid: @to_mid)
      event['userId']
    when 'group'
      event['groupId']
    when 'room'
      event['roomId']
    end
  end

  def receive_follow
    @client.push_message(
      @message_target,
      {
        type: 'text',
        text: '友達登録ありがとうございます！'
      }
    )
  end

  def receive_unfollow
  end

  def receive_join
    @client.push_message(
      @message_target,
      {
        type: 'text',
        text: '招待ありがとうございます！'
      }
    )
  end

  def receive_leave
  end

  def receive_postback(event)
    q = event["postback"]["data"].split(",")
    case q[0]
    when 'edit'
      remind = Remind.find(q[1])
      remind.activate!
      send_text("「#{remind.name}」のイベントを作成しました")
    end
  end

  def remind_activate
  end

  def receive_text(event)
    datetime = contain_date(event['message']['text'])
    if datetime.present?
      group = Group.find_by_event(event)
      date_ja = datetime.strftime("%m月%d日%H時%M分")
      remind_at = datetime - Rational(1, 24)
      remind = Remind.create(group_id: group.id, name: date_ja, body: "#{date_ja}の予定", datetime: datetime, at: remind_at)
      send_templete_button(remind.name, remind.body, remind.new_actions)
    end
  end

  def echo_image(event)
    @client.reply_message(event['replyToken'], {
      type: 'text',
      text: 'イメージだよ'
    })
  end

  def echo_video(event)
    @client.reply_message(event['replyToken'], {
      type: 'text',
      text: '動画だよ'
    })
  end

  def echo_audio(message, event)
    @client.reply_message(event['replyToken'], {
      type: 'text',
      text: '音声だよ'
    })
  end

  def echo_location(event)
    @client.reply_message(event['replyToken'], {
      type: 'location',
      title: event['message']['title'],
      address: event['message']['address'],
      latitude: event['message']['latitude'],
      longitude: event['message']['longitude']
    })
  end

  def echo_sticker(event)
    @client.reply_message(event['replyToken'], {
      type: 'sticker',
      package_id: event['message']['packageId'],
      sticker_id: event['message']['stickerId']
    })
  end

  # messaging methods
  def contain_date(text)
    datte = Datte::Parser.new()
    datte.parse_date(text)
  end

  def send_text(text)
    @client.reply_message(@event['replyToken'], {
      type: 'text',
      text: text
    })
  end

  def send_templete_button(title, body, actions)
    @client.reply_message(@event['replyToken'], {
      "type": "template",
      "altText": "ご使用の端末は対応していません",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://www.google.co.jp/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png",
          "title": title,
          "text": body,
          "actions": actions
      }
    })
  end
end
