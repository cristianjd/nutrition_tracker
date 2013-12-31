class UsersController < ApplicationController
  before_filter :correct_user, :except => [:new, :create]

  def show
    @user = current_user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in(@user, false)
      flash[:success] = "Account successfully created. Link with FatSecret to proceed."
      redirect_to account_path
    else
      flash[:error] = @user.errors.full_messages.first if @user.errors.any?
      redirect_to signup_path
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.authenticate(params[:user].delete(:current_password))
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      if @user.update_attributes(params[:user])
        flash[:success] = "Account successfully updated."
        redirect_to account_path
      else
        flash[:error] = @user.errors.full_messages.first if @user.errors.any?
        redirect_to edit_account_path
      end
    else
      flash[:error] = "Current password is invalid."
      redirect_to edit_account_path
    end
  end

  def destroy
    @user = current_user
    @user.destroy
    flash[:success] = "Account successfully deleted."
    redirect_to root_path
  end

  def nutrition
    @user = current_user
    if current_user.api_tokens.empty?
      redirect_to account_path and return
    end
    if params[:date]
      date = Date.strptime(params[:date], '%m-%d-%Y')
      nutrient_data = @user.get_nutrient_data(date)
      @data = { :date => date,
                :current_nutrients => nutrient_data[:current_nutrients],
                :goal_nutrients => nutrient_data[:goal_nutrients],
                :remaining_nutrients => nutrient_data[:remaining_nutrients] }
    else
      today = Date.today.strftime('%m-%d-%Y')
      if params[:id]
        redirect_to user_nutrition_path(@user, :date => today)
      else
        redirect_to nutrition_path(:date => today)
      end
    end
  end

  private

    def correct_user
      if signed_in?
        if params[:id] and (params[:id] != "#{current_user.id}")
          redirect_to :action => params[:action], :id => current_user.id
        end
      else
        flash[:error] = "Must be signed in to proceed."
        redirect_to login_path
      end
    end

end
