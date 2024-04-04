class ChatsController < ApplicationController
  before_action :following_check, only: [:show]

  def show

  end

  private
  def following_check
    user = User.find(params[:id])
    unless current_user.following?(user) && user.following?(current_user)
      redirect_to books_path
    end
  end

end
