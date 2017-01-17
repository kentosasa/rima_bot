class UsersController < ApplicationController
  def new
    @schedule = Schedule.find(params[:id])
    @candidates = @schedule.candidates
    @user = User.new
    @user.candidates.build
  end

  def create
  end
end
