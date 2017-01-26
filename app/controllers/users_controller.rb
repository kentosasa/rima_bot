class UsersController < ApplicationController
  before_action :set_schedule, only: [:new, :edit, :update, :create]
  before_action :set_group
  def new
    @user = @schedule.users.new
  end

  def create
    @user = @schedule.users.new(user_params)
    @user.answer = answer
    if @user.save
      flash[:success] = '出欠を回答しました。'
      redirect_to remind_path(@schedule.uid)
    else
      flash[:warning] = '回答に失敗しました。'
      render 'new'
    end
  end

  def edit
    @user = @schedule.users.find_by(id: params[:user_id])
    @answers = @user.answer.split(',')
  end

  def update
    @user = @schedule.users.find_by(id: params[:user_id])
    @user.answer = answer

    if @user.update(user_params)
      flash[:success] = '出欠を更新しました。'
      redirect_to remind_path(@schedule.uid)
    else
      flash[:warning] = '回答に失敗しました。'
      render 'edit'
    end
  end

  private
  def answer
    answers = []
    params[:candidate].each do |cd|
      id = cd[:id].to_i
      answer = params["candidate_#{id}"][:attendance]
      answers.push(answer)
    end
    answers.join(',')
  end

  def set_schedule
    @schedule = Schedule.find_by(uid: params[:id])
    @candidates = @schedule.candidate_body.each_line.map(&:chomp)
  end

  def user_params
    params.require(:user).permit(:name, :comment)
  end
end
