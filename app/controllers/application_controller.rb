class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  private
  def set_group
    id = params[:id]
    @remind ||= Remind.find_by(uid: id) || Remind.find_by(id: id)
    @group ||= Group.find_by(id: id) || @remind.group
  end
end
