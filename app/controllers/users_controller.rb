class UsersController < ApplicationController
  def new
    @schedule = Schedule.find(params[:id])
    @candidates = @schedule.candidates
    @user = User.new

    @user.candidates.build
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
    redirect_to remind_path(params[:id])
  end

  private
  def user_params
    params.require(:user).permit(:name)
  end
end
