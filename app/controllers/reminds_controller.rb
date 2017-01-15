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
  end

  def create
  end

  def edit
    @date, @time = @remind.parse_datetime
  end

  def update
    @remind.datetime = combine_datetime
    @remind.ad = remind_at(@remind.datetime)
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
    before = params[:before].to_i
    datetime - Rational(before, 24)
  end

  def set_remind
    @remind = Remind.find(params[:id])
  end

  def combine_datetime
    "#{params[:date]} #{params[:time]}"
  end

  def remind_params
    params.require(:remind).permit(:name, :body, :scale, :place)
  end
end
