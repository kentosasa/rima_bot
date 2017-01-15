class RemindsController < ApplicationController
  before_action :set_remind, only: [:show, :edit, :update, :destroy, :activate]
  before_action :set_gmap, only: [:show, :edit, :update]
  before_action :set_before, only: [:show, :edit, :activate]

  def index
  end

  def new
    @remind = Remind.new
  end

  def show
  end

  def activate
    @remind.activate!
  end

  def create
  end

  def edit
    @date, @time = @remind.parse_datetime
  end

  def update
    @remind.datetime = combine_datetime
    @remind.at = remind_at(@remind.datetime)
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
    @remind = Remind.find(params[:id])
  end

  def combine_datetime
    dt = params.require(:remind).permit(:date, :time)
    "#{dt[:date]} #{dt[:time]}"
  end

  def remind_params
    params.require(:remind).permit(:name, :body, :scale, :place, :address, :longitude, :latitude)
  end
end
