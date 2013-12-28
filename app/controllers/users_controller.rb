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
    redirect_to account_path
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    redirect_to account_path
  end

  def destroy
    @user = current_user
    @user.destroy
    redirect_to account_path
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
        if params[:id] != current_user.id
          redirect_to :action => params[:action], :id => current_user.id
        end
      else
        redirect_to login_path
      end
    end

end
