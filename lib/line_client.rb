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
    @messaging = Messaging.new(event, client, @group)
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
    @messaging.reply_text("友達登録ありがとうございます。\n私はグループ内の会話からリマインドや日程調整のサポートをするBOTです。是非、グループに参加してみてください！よろしくお願いします:)")
  end

  def receive_unfollow; end

  def receive_join
    @messaging.reply_text("友達登録ありがとうございます。\n私はグループ内の会話からリマインドや日程調整のサポートをするBOTです。よろしくお願いします:)")
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
      @messaging.reply_confirm(text, remind.active_actions)
    else
      @messaging.reply_text('通知設定に失敗')
    end
  end

  # リマインド(id)を無効化
  def inactivation(id)
    remind = Remind.find(id)
    if remind.inactivate!
      text = "[#{remind.name}]\nリマインド設定を取り消しました。"
      @messaging.reply_confirm(text, remind.show_actions)
    else
      @messaging.reply_text('通知取り消しに失敗')
    end
  end

  # リマインドを10分後に再通知
  def snooze(id)
    remind = Remind.find(id)
    if remind.snooze!(10)
      @messaging.reply_text("#{remind.at.strftime("%m月%d日%H時%M分")}に再通知します")
    else
      @messaging.reply_text('再通知の設定に失敗')
    end
  end

  def add_remind(body, datetime)
    remind_at = datetime.ago(1.hour)
    name = datetime.strftime("%m/%dのイベント")

    remind = @group.reminds.new(
      name: name,
      body: body,
      datetime: datetime,
      at: remind_at,
      type: 'Event'
    )

    if remind.save
      @messaging.reply_buttons(name, body, remind.create_actions)
    else
      @messaging.reply_text('保存失敗')
    end
  end

  def show_remind(datetime)
    reminds = @group.reminds.active.between(datetime.beginning_of_day, datetime.end_of_day).limit(3)
    columns = reminds.map { |item| item.show_column }
    if reminds.present? && reminds[0].latitude.present? && reminds[0].longitude.present?
      ad = Ad.new(reminds[0].latitude, reminds[0].longitude)
      ad_column = ad.column
      columns.push(ad_column) if ad_column.present?
    end
    @messaging.reply_carousel(columns)
  end

  def show_all_reminds
    reminds = @group.reminds.active.between(DateTime.now, nil).limit(5)
    columns = reminds.map { |item| item.show_column }
    @messaging.reply_carousel(columns)
  end

  def receive_text(event)
    body = event['message']['text']

    if body.include?('予定一覧')
      show_all_reminds
    end

    datte = Datte::Parser.new
    datte.parse_date(body) do |datetime| # 日付を含んだ処理
      if body.include?('何')
        show_remind(datetime)
      else
        add_remind(body, datetime)
      end
      return
    end

    @messaging.reply_text('日付を含みませんでした。')
  end

  def echo_image(event)
    @messaging.reply_text('イメージだよ')
  end

  def echo_video(event)
    @messaging.reply_text('動画だよ')
  end

  def echo_audio(event)
    @messaging.reply_text('音声だよ')
  end

  def echo_location(event)
    title, address = event['message']['title'], event['message']['address']
    lat, lng = event['message']['latitude'], event['message']['longitude']
    @messaging.reply_location(title, address, lat, lng)
  end

  def echo_sticker(event)
    @messaging.reply_sticker(event['message']['packageId'], event['message']['stickerId'])
  end
end
