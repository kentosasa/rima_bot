class Messaging
  def initialize(event, client)
    @event = event
    @client = client
  end

  def reply_text
  end

  private

  def include_date?
    return true
  end

  def send_text(text)
    @client.reply_message(event['replyToken'], {
      type: 'text',
      text: text
    })
  end
end
