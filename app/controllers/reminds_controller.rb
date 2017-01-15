class RemindsController < ApplicationController
  before_action :set_remind, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @remind = Remind.new

  end

  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  private
  def set_remind
    @remind = Remind.find(params[:id])
  end
end
