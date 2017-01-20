class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  private
  def set_group
    id = params[:id]
    @group ||= Group.find_by_id(id) || Remind.find_by_id(id).group
  end
end
