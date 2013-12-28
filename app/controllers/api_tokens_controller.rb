class ApiTokensController < ApplicationController
  before_filter :signed_in_user

  def create
    auth = omniauth(request.env['omniauth.auth'])
    user_id = request.env['omniauth.params']['user_id']
    origin = request.env['omniauth.origin']

    @user = User.find(user_id)

    @new_api = @user.api_tokens.build(auth)

    if @new_api.save
      flash[:success] = "Successfully linked account with FatSecret."
      redirect_to origin
    end
  end

  def destroy
    User.find(current_user).api_tokens.find(params[:id]).destroy
    flash[:success] = "Successfully unlinked account from FatSecret."
    redirect_to account_path
  end

  private

    def signed_in_user
      redirect_to login_path unless signed_in?
    end

    def omniauth auth
      params = {
          "provider" => auth['provider'],
          "auth_token" => auth['credentials']['token'],
          "auth_secret" => auth['credentials']['secret']
      }
    end
end
