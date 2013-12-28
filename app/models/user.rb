class User < ActiveRecord::Base
  has_many :api_tokens, :dependent => :destroy

  attr_accessible :calories, :carbohydrate_ratio, :fat_ratio, :password, :password_confirmation, :protein_ratio, :username
  has_secure_password

  validates :username, :presence => true, :length => { minimum: 6, maximum: 20 }, :uniqueness => true
  validates :password, :presence => true, :length => { minimum: 6 }
  validates :password_confirmation, :presence => true
  validates :calories, :protein_ratio, :carbohydrate_ratio, :fat_ratio, :presence => true, :numericality => true
  validates_with RatioValidator

  before_save :create_remember_token
  after_validation { self.errors.messages.delete(:password_digest) }

  NUTRIENTS = %w{calories protein carbohydrate fat}

  def get_nutrient_data(date)
    current_nutrients = get_current_nutrients(date)
    goal_nutrients = get_goal_nutrients
    remaining_nutrients = get_remaining_nutrients(current_nutrients, goal_nutrients)
    {:current_nutrients => current_nutrients, :goal_nutrients => goal_nutrients, :remaining_nutrients => remaining_nutrients}
  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

    def extract_total(response, nutrient)
      Nokogiri::XML(response).css(nutrient).children.inject(0.0) {|total, match| total + match.text.to_s.to_i}
    end

    def get_current_nutrients(date)
      tokens = self.api_tokens.find_by_provider('fatsecret')
      date_int = (date - Date.new(1970,1,1)).to_i
      request = Fatsecret::Api.new({}).api_call(
          ENV['FATSECRET_KEY'],
          ENV['FATSECRET_SECRET'],
          {:date => date_int,
           :method => 'food_entries.get'},
          tokens['auth_token'] ||= "",
          tokens['auth_secret'] ||= ""
      )
      Hash[NUTRIENTS.zip(NUTRIENTS.collect {|nutrient| extract_total(request.body, nutrient).round(1)})]
    end

    def get_goal_nutrients
      Hash[NUTRIENTS.zip([self.calories.round(1),
                          ((self.calories*(self.protein_ratio/100.0))/4.0).round(1),
                          ((self.calories*(self.carbohydrate_ratio/100.0))/4.0).round(1),
                          ((self.calories*(self.fat_ratio/100.0))/9.0).round(1)])]
    end

    def get_remaining_nutrients(current_nutrients, goal_nutrients)
      goal_nutrients.merge(current_nutrients) { |key, goal, current| (goal - current).round(1) }
    end

end
