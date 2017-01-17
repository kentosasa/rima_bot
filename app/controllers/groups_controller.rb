class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :reminds]

  def show
    @reminds = @group.reminds
  end

  def edit
  end

  def update
    if @group.update(group_params)
      flash[:success] = '設定を更新しました。'
      redirect_to group_path(@group)
    else
      render 'edit'
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
