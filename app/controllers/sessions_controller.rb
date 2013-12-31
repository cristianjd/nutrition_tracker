class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:session][:username])
    if user && user.authenticate(params[:session][:password])
      if params[:session][:remember_me] == "1"
        sign_in(user, true)
      else
        sign_in(user, false)
      end
      if user.api_tokens.empty?
        redirect_to account_path, :notice => "Successfully logged in."
      else
        redirect_to nutrition_path, :notice => "Successfully logged in."
      end
    else
      redirect_to login_path, :alert => "Invalid username or password."
    end
  end

  def destroy
    sign_out
    redirect_to root_path, :notice => "Successfully logged out."
  end
end
