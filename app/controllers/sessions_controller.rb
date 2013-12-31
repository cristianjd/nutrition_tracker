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
      flash[:success] = "Successfully signed in."
      if user.api_tokens.empty?
        redirect_to account_path
      else
        redirect_to nutrition_path
      end
    else
      flash[:error] = "Invalid username or password."
      redirect_to login_path
    end
  end

  def destroy
    sign_out
    flash[:success] = "Successfully signed out."
    redirect_to root_path
  end
end
