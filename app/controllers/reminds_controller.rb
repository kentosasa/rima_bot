class RemindsController < ApplicationController
  before_action :set_remind, only: [:show, :edit, :update, :destroy, :activate, :inactivate]
  before_action :set_gmap, only: [:show, :edit, :update]
  before_action :set_before, only: [:show, :edit, :activate]

  def new
    @remind = Remind.new
    gon.autoComplete = true
  end

  def show
  end

  def activate
    @remind.activate!
  end

  def inactivate
    @remind.inactivate!
  end

  def create
    gon.autoComplete = true
  end

  def edit
    @date, @time = @remind.parse_datetime
    gon.autoComplete = true
    gon.remindType = @remind.type || 'Event'
  end

  def update
    @remind.type = params.require(:remind).permit(:remind_type)[:remind_type]
    @remind.datetime = combine_datetime
    @remind.at = remind_at(@remind.datetime)
    gon.autoComplete = true
    gon.remindType = @remind.type || 'Event'
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
    before = params.require(:remind).permit(:before)[:before].to_i
    datetime - before * 60
  end

  def set_before
    @remind.before = (@remind.datetime - @remind.at).to_i / 60
  end

  def set_remind
    @remind = remind_class.find(params[:id])
  end

  def combine_datetime
    dt = params.require(:remind).permit(:date, :time)
    "#{dt[:date]} #{dt[:time]}"
  end

  def remind_params
    params.require(:remind).permit(:name, :body, :scale, :place, :address, :longitude, :latitude)
  end

  # Event or Schedule
  def type
    params[:type]
  end

  def remind_params
    #params.require(type.underscoe.to_sym).permit(:name, :body)
  end

  def remind_class
    return Remind if type.blank?
    type.constantize
  end
end
