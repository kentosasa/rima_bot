class LineClient
  MESSAGE_TYPE_TO_METHOD_MAP = {
    'text' => :echo_text,
    'image' => :echo_image,
    'video' => :echo_video,
    'audio' => :echo_audio,
    'location' => :echo_location,
    'sticker' => :echo_sticker
  }.freeze
  HOST = 'link'.freeze

  def initialize(client, event)
    @client = client
    @event = event
    @message_target = find_or_create_message_target(@event)
  end

  def reply
    case @event
    when Line::Bot::Event::Message
      send(MESSAGE_TYPE_TO_METHOD_MAP[event.type.to_s], event)
      # message = Message.new(message_target)
      #
      #
      #   message = Message.new(message_target_id: message_target.id, message_target_type: event["source"]["type"
      #   send(MESSAGE_TYPE_TO_METHOD_MAP[event.type.to_s], message, event)
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
      @user = User.find_or_create_by(mid: @to_mid)
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
    text = Messaging.new(event, @client).reply_text
    @client.reply_message(evet['replyToken'], {
      type: 'text',
      text: text
      #text: event['message']['text']
    })
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
end
