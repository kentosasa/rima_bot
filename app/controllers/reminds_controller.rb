class RemindsController < ApplicationController
  before_action :set_remind, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
    @remind = Remind.new
  end

  def show
    #gon.lat = @remind.latitude
    #gon.lng = @remind.longitude
    @remind.before = (@remind.datetime - @remind.at).to_i / 60
  end

  def create
  end

  def edit
    @date, @time = @remind.parse_datetime
    @remind.before = (@remind.datetime - @remind.at).to_i / 60
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

  def remind_at(datetime)
    before = params.require(:remind).permit(:before)[:before].to_i
    datetime - before * 60
  end

  def set_remind
    @remind = Remind.find(params[:id])
  end

  def combine_datetime
    dt = params.require(:remind).permit(:date, :time)
    "#{dt[:date]} #{dt[:time]}"
  end

  def remind_params
    params.require(:remind).permit(:name, :body, :scale, :place)
  end
end
