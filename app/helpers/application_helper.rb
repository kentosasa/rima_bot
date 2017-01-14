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
end
