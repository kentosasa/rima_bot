module ApplicationHelper
  def flash_message(flash)
    msg = flash.map do |type, message|
      content_tag :div, class: "notification is-#{type}" do
        concat content_tag :button, '', class: 'delete'
        concat message
      end
    end
    safe_join(msg)
  end

  def default_meta_tags
    {
      site: 'リマさんBOT',
      reverse: true,
      separator: '|',
      title: 'リマさん',
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1.0'
    }
  end

  def top_meta_tags
    {
      site: 'LINEで使える簡単リマインドBOT リマさん',
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1.0',
      keywords: 'LINE,BOT,リマインド,通知,簡単,日程調整',
      description: 'LINEで友達と、家族とサークルで使える簡単リマインドBOT リマさんです。BOTを意識することなく、通知や日程調整のサポートをしてくれます。',
      open_graph: {
        title: 'LINEで使える簡単リマインドBOT リマさん',
        url: request.original_url
      },
      og: {
        title: 'LINEで使える簡単リマインドBOT リマさん',
        type: 'website',
        url: request.original_url,
        image: asset_path('logo.png'),
        site_name: 'リマさん',
        description: 'LINEで友達と、家族とサークルで使える簡単リマインドBOT リマさんです。BOTを意識することなく、通知や日程調整のサポートをしてくれます。',
        localer: 'ja_JP'
      },
      twitter: {
        card: 'summary',
        #site: ''
        title: 'LINEで使える簡単リマインドBOT リマさん',
        description: 'LINEで友達と、家族とサークルで使える簡単リマインドBOT リマさんです。BOTを意識することなく、通知や日程調整のサポートをしてくれます。',
        image: asset_path('logo.png')
      }
    }
  end

  def original_url
    ENV['WEBHOOK_URL'] #+ request.fullpath
  end
end
