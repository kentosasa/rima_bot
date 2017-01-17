class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :reminds]

  def show
    @reminds = @group.reminds
  end

  def edit
  end

  def update
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end
end
