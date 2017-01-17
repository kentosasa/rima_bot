class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :set_group

  private
  def set_group
    id = params[:id]
    @group ||= Group.find_by_id(id) || Remind.find_by_id(id).group
  end
end
