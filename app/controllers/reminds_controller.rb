require 'line/bot'

class RemindsController < ApplicationController
  include Rima
  include ActionView::Helpers::TextHelper
  before_action :set_group
  before_action :set_remind, only: [:show, :edit, :update, :destroy, :activate, :inactivate]
  before_action :set_gmap, only: [:edit, :update]
  before_action :set_before, only: [:show, :edit, :activate]

  def new
    @remind = @group.reminds.new
    @remind.type = params[:type] || 'Event'
    gon.autoComplete = true
    gon.lat = 35.6586488
    gon.lng = 139.6966408
    gon.create = true
    gon.remindType = params[:type] || 'Event'
  end

  def create
    @remind = @group.reminds.new(remind_params)
    @remind.type = params.require(type.downcase.to_sym).permit(:remind_type)[:remind_type]
    @remind.datetime = combine_datetime
    @remind.at = remind_at(@remind.datetime)
    if @remind.save
      flash[:success] = 'リマインドを作成しました。'
      redirect_to group_path(@group)
    else
      render 'new'
    end
  end

  def show
    gon.lat = @remind.latitude
    gon.lng = @remind.longitude
    if @remind.schedule?
      @candidates = @remind.candidate_body.each_line.map(&:chomp)
    end
  end

  def activate; @remind.activate! end
  def inactivate; @remind.inactivate! end

  def edit
    @date, @time = @remind.parse_datetime
    gon.autoComplete = true
    gon.remindType = @remind.type || 'Event'

    if @remind.schedule?
      @candidates = @remind.candidate_body.each_line.map(&:chomp)
    end
  end

  def update
    @remind.type = params.require(type.downcase.to_sym).permit(:remind_type)[:remind_type]
    @remind.datetime = combine_datetime
    @remind.at = remind_at(@remind.datetime)
    if !@remind.activated? && @remind.activated!
      text = truncate(@remind.body, length: 25) + "\n" + @remind.active_text
      client.push_message(@remind.group.source_id, {
        type: 'template',
        altText: text,
        template: {
          type: 'buttons',
          title: @remind.name,
          text: text,
          actions: @remind.active_actions
        }
      })
    end

    if @remind.update(remind_params)
      flash[:success] = 'リマインドを更新しました。'
      redirect_to remind_path(@remind)
    else
      render 'edit'
    end
  end

  def destroy; end

  private

  def set_gmap
    gon.lat = @remind.latitude || 35.6586488
    gon.lng = @remind.longitude || 139.6966408
  end

  def remind_at(datetime)
    before = params.require(type.downcase.to_sym).permit(:before)[:before].to_i
    datetime - before * 60
  end

  def set_before
    @remind.before = (@remind.datetime - @remind.at).to_i / 60
  end

  def set_remind
    @remind = remind_class.find_by(uid: params[:id]) || remind_class.find_by(id: params[:id])
  end

  def combine_datetime
    dt = params.require(type.downcase.to_sym).permit(:date, :time)
    "#{dt[:date]} #{dt[:time]}"
  end

  # Event or Schedule
  def type
    params[:type] || 'Remind'
  end

  def remind_params
    params.require(type.downcase.to_sym).permit(:name, :body, :place, :address, :longitude, :latitude, :candidate_body)
  end

  def remind_class
    return Remind if type.blank?
    type.constantize
  end
end
