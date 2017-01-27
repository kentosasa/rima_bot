module Rima
  class Client
    include Rima
    MESSAGE_TYPE_TO_METHOD_MAP = {
      'text' => :receive_text,
      'image' => :receive_image,
      'video' => :receive_video,
      'audio' => :receive_audio,
      'location' => :receive_location,
      'sticker' => :receive_sticker
    }.freeze

    RIMASAN = Regexp.compile('りまさん|rimasan|リマさん|rima_san')
    NEGATIVE = Regexp.compile('無理|ムリ|むり|ダメ|だめ|駄目|できない|厳しい|きびしい')
    PLANS = Regexp.compile('予定一覧|リマインド一覧')
    SCHEDULE = Regexp.compile('いつにする?|いつにする？|日程調整|スケジュール調整|いつがいい?|いつにしよう?|行ける人おしえてくださいー|何日にする-?')

    def initialize(client, event)
      @event = event
      @group = Group.find_or_create(event)
      @message = Rima::Message.new(@group, @event)
      hello() if @group.new_record?
      @group.update_profile(@message.get_profile) if @group.name.nil?
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

    def receive_follow
      @message.push_message(@group.self_intro)
    end

    def receive_unfollow; end

    def receive_join
      @message.push_message(@group.self_intro)
    end

    def receive_leave; end

    def receive_postback(event)
      query = Rack::Utils.parse_nested_query(event['postback']['data'])
      remind = Remind.find_by(id: query['remind_id'])
      case query['action']
      when 'activate' then
        reply = remind.activate!
        @message.reply_buttons(*reply) if reply.present?
      when 'inactivate' then
        reply = remind.inactivate!
        @message.reply_text(reply) if reply.present?
      when 'snooze' then
        reply = remind.snooze!
        @message.reply_text(reply) if reply.present?
      end
    end

    def receive_text(event)
      body = event['message']['text']

      # 名前を呼ばれると自己紹介
      if RIMASAN === body
        @message.reply_text(@group.self_intro)
        return
      end

      # ネガティブワードがあれば反応しない
      return if NEGATIVE === body

      # 予定一覧やスケジュール一覧で予定を返す
      if PLANS === body
        show_all_reminds
        return
      end

      if SCHEDULE === body
        create_schedule(body, Time.zone.now + 7)
        return
      end

      datte = Datte::Parser.new
      datte.parse_date(body) do |datetime| # 日付を含んだ処理
        if /何/ === body
          show_remind(datetime)
        else
          create_event(body, datetime)
        end
      end
    end


    ########################################


    def create_remind(body, datetime, type, name = nil)
      between = datetime.to_time.to_i - Time.zone.now.to_time.to_i
      if between < 60 * 60 * 10
        remind_at = datetime
      else
        remind_at = datetime.ago(1.hour)
      end
      @group.reminds.new(
        name: name || datetime.strftime("%-m/%-dのイベント"),
        body: body,
        datetime: datetime,
        at: remind_at,
        type: type,
        status: :created
      )
    end

    def create_event(body, datetime)
      event = create_remind(body, datetime, 'Event')
      if event.save
        @message.reply_text(@group.create_event_text)
        @message.push_buttons(event.name, body + event.emoji, event.create_actions)
      end
    end

    def create_schedule(body, datetime)
      schedule = create_remind(body, datetime, 'Schedule', '日程調整')
      if schedule.save
        @message.push_buttons('日程調整', @group.create_schedule_text, schedule.schedule_actions)
      end
    end

    def show_remind(datetime)
      reminds = @group.reminds.active.between(datetime.beginning_of_day, datetime.end_of_day).limit(3)
      columns = reminds.map { |remind| remind.show_column }
      if reminds.present? && reminds[0].latitude.present? && reminds[0].longitude.present?
        ad = Ad.new(reminds[0].latitude, reminds[0].longitude)
        ad_column = ad.column
        columns.push(ad_column) if ad_column.present?
      end
      text = datetime.strftime("%-m月%-d日の予定ですよ！")
      @message.reply_text(text)
      @message.push_carousel(text, columns)
    end

    def show_all_reminds
      reminds = @group.reminds.active.between(Time.zone.now, nil).limit(5)
      columns = reminds.map { |remind| remind.show_column }
      text = columns.size.zero? ?
        @group.zero_plan_text : @group.plan_exist_text
      @message.reply_text(text)
      @message.push_carousel(text, columns)
    end

    # はじめましての時の一言
    def hello
      @message.push_buttons('はじめまして', '初めまして。僕の設定はここで設定できるよ！', @group.first_actions)
    end

    ############### その他 ####################

    def receive_image(event); logger.debug 'image' end
    def receive_video(event); logger.debug 'video' end
    def receive_audio(event); logger.debug 'audio' end
    def receive_location(event); logger.debug 'location' end
    def receive_sticker(event); logger.debug 'sticker' end
  end
end
