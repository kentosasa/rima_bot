module Rima
  class Message
    include Rima
    include ActionView::Helpers::TextHelper
    def initialize(group, event)
      @group = group
      @event = event
    end

    def push_message(text)
      client.push_message(@group.source_id, {
        type: 'text',
        text: text
      })
    end

    def push_buttons(title, text, actions)
      client.push_message(@group.source_id, {
        type: 'template',
        altText: truncate(text, length: 30),
        template: {
          type: 'buttons',
          #title: title,
          text: text,
          actions: actions
        }
      })
    end

    def push_carousel(text, columns)
      client.push_message(@group.source_id, {
        type: 'template',
        altText: text,
        template: {
          type: 'carousel',
          columns: columns
        }
      })
    end

    def reply_sticker(package_id, sticker_id)
      client.reply_message(@event['replyToken'], {
        type: 'sticker',
        package_id: package_id,
        sticker_id: sticker_id
      })
    end

    def reply_location(title, address, lat, lng)
      client.reply_message(@event['replyToken'], {
        type: 'location',
        title: title,
        address: address,
        latitude: lat,
        longitude: lng
      })
    end

    def reply_text(text)
      client.reply_message(@event['replyToken'], {
        type: 'text',
        text: text
      })
    end

    def reply_confirm(text, actions)
      client.reply_message(@event['replyToken'], {
        type: 'template',
        altText: truncate(text, length: 30),
        template: {
          type: 'confirm',
          text: text,
          actions: actions
        }
      })
    end

    def reply_buttons(title, text, actions)
      client.reply_message(@event['replyToken'], {
        type: 'template',
        altText: truncate(text, length: 30),
        template: {
          type: 'buttons',
          title: title,
          text: text,
          actions: actions
        }
      })
    end

    def reply_carousel(columns)
      client.reply_message(@event['replyToken'], {
        type: "template",
        altText: 'hogehohge',
        template: {
          type: "carousel",
          columns: columns
        }
      })
    end

    def push_notify(columns)
      client.push_message(@group.source_id, {
        type: "template",
        altText: "push_notify",
        template: {
          type: "carousel",
          columns: columns
        }
      })
    end
  end
end
