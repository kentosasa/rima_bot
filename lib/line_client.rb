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
    @group = Group.find_or_create(event)
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
      receive_postback
    end
  end

  private

  def receive_follow
    push_message("友達登録ありがとうございます。\n私はグループ内の会話からリマインドや日程調整のサポートをするBOTです。是非、グループに参加してみてください！よろしくお願いします:)")
  end

  def receive_unfollow; end

  def receive_join
    push_message("友達登録ありがとうございます。\n私はグループ内の会話からリマインドや日程調整のサポートをするBOTです。よろしくお願いします:)")
  end

  def receive_leave; end

  def receive_postback
    query = Rack::Utils.parse_nested_query(@event["postback"]["data"])
    id = query['remind_id']
    case query['action']
    when 'activate' then activation(id)
    when 'inactivate' then inactivation(id)
    when 'snooze' then snooze(id)
    end
  end

  # リマインド(id)を有効化
  def activation(id)
    remind = Remind.find(id)
    if remind.activate!
      text = "[#{remind.name}]\n#{remind.datetime.strftime('%m/%d %H:%m')}の#{remind.before}前にリマインドを設定しました。"
      reply_confirm(text, remind.active_actions)
    else
      reply_text('通知設定に失敗')
    end
  end

  # リマインド(id)を無効化
  def inactivation(id)
    remind = Remind.find(id)
    if remind.inactivate!
      text = "[#{remind.name}]\nリマインド設定を取り消しました。"
      reply_confirm(text, remind.inactiva_actions)
    else
      reply_text('通知取り消しに失敗')
    end
  end

  # リマインドを10分後に再通知
  def snooze(id)
    remind = Remind.find(1)
    if remind.snooze!(10)
      reply_text("#{remind.at.strftime("%m月%d日%H時%M分")}に再通知します")
    else
      reply_text('再通知の設定に失敗')
    end
  end

  def receive_text(event)
    body = event['message']['text']
    datte = Datte::Parser.new
    datte.parse_date(body) do |datetime|
      remind_at = datetime.ago(1.hour)
      name = datetime.strftime("%m/%dのイベント")

      remind = @group.reminds.new(
        name: name,
        datetime: datetime,
        at: remind_at,
        type: 'Event'
      )

      if remind.save
        reply_buttons(name, body, remind.create_actions)
      else
        reply_text('保存失敗')
      end
      return
    end
    reply_text('日付を含みませんでした。')
  end

  def echo_image(event)
    reply_text('イメージだよ')
  end

  def echo_video(event)
    reply_text('動画だよ')
  end

  def echo_audio(event)
    reply_text('音声だよ')
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

  def push_message(text)
    @client.push_message(@group.source_id, {
      type: 'text',
      text: text
    })
  end

  def reply_text(text)
    @client.reply_message(@event['replyToken'], {
      type: 'text',
      text: text
    })
  end

  def reply_confirm(text, actions)
    @client.reply_message(@event['re plyToken'], {
      type: 'template',
      altText: text,
      template: {
        type: 'confirm',
        text: text,
        actions: actions
      }
    })
  end

  def reply_buttons(title, text, actions)
    @client.reply_message(@event['replyToken'], {
      'type': 'template',
      'altText': 'ご使用の端末は対応していません',
      'template': {
        'type': 'buttons',
        #thumbnailImageUrl: image,
        'title': title,
        'text': text,
        'actions': actions
      }
    })
  end

  def reply_templete(template)
    @client.reply_message(@event['replyToken'], template)
  end
end
