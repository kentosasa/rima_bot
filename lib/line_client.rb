class LineClient
  MESSAGE_TYPE_TO_METHOD_MAP = {
    'text' => :echo_text,
    'image' => :echo_image,
    'video' => :echo_video,
    'audio' => :echo_audio,
    'location' => :echo_location,
    'sticker' => :echo_sticker
  }.freeze
  HOST = 'https://5498377a.ngrok.io'.freeze

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

  def echo_text(event)
    replay_message
    #text = Messaging.new(event, @client).reply_text
    # @client.reply_message(event['replyToken'], {
    #   type: 'text',
    #   text: event['message']['text']
    # })
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
  private
  def replay_message
    if include_date?
      remind = Remind.create(name: '1/15', body: '1/15 schedule')
      send_templete_button(remind.name, remind.body, remind.default_actions)
    end
  end

  def include_date?
    return true
  end

  def send_text(text)
    @client.reply_message(event['replyToken'], {
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
