class Messaging
  def initialize(event, client)
    @event = event
    @client = client
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

  def reply_carousel(columns)
    @client.reply_message(@event['replyToken'],
    {
      "type": "template",
      "altText": "ご使用の端末は対応しておりません",
      "template": {
        "type": "carousel",
        "columns":
          columns
      }
    })
  end
end
