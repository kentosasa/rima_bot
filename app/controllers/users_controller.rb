class UsersController < ApplicationController
  before_action :set_schedule, only: [:new, :edit, :update, :create]
  before_action :set_group
  def new
    @candidates = @schedule.candidates
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    params[:candidate].each do |cd|
      id = cd[:id].to_i
      answer = params["candidate_#{id}"][:attendance]
      candidate_user = CandidateUserRelation.new(
        candidate_id: id,
        user_id: @user.id,
        attendance: answer.to_sym
      )
      candidate_user.save
    end
    flash[:success] = '出欠を回答しました。'
    redirect_to remind_path(@schedule.uid)
  end

  def edit
    @candidates = @schedule.candidates
    @user = User.find_by(id: params[:user_id])
  end

  def update
    @user = User.find(params[:user_id])
    @user.update(user_params)
    params[:candidate].each do |cd|
      id = cd[:id].to_i
      answer = params["candidate_#{id}"][:attendance]
      candidate_user = CandidateUserRelation.find_by(
        candidate_id: id,
        user_id: @user.id
      )
      candidate_user.update(attendance: answer.to_sym)
    end
    flash[:success] = '出欠を更新しました。'
    redirect_to remind_path(@schedule.uid)
  end

  private
  def set_schedule
    @schedule = Schedule.find_by(uid: params[:id])
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
