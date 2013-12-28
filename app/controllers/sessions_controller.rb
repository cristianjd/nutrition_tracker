class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_name(params[:session][:name])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      if user.api_tokens.empty?
        redirect_to user_path
      else
        redirect_to nutrition_path
      end

    else
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
