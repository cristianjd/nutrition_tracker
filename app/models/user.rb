class User < ActiveRecord::Base
  has_many :api_tokens, :dependent => :destroy

  attr_accessible :calories, :carbohydrate_ratio, :fat_ratio, :password, :password_confirmation, :protein_ratio, :username
  has_secure_password

  validates :username, :presence => true, :length => { minimum: 6, maximum: 20 }, :uniqueness => true
  validates :password, :presence => true, :confirmation => true, :length => { minimum: 6 }, :if => :password_changed?
  validates :calories, :protein_ratio, :carbohydrate_ratio, :fat_ratio, :presence => true, :numericality => true
  validates_with RatioValidator

  before_create :create_remember_token
  after_validation { self.errors.messages.delete(:password_digest) }

  NUTRIENTS = %w{calories protein carbohydrate fat}

  def get_nutrient_data(date)
    date_int = (date - Date.new(1970,1,1)).to_i
    entries = sanitize_response(fatsecret_api_call({:date => date_int, :method => 'food_entries.get', :format => "json"}))
    current_nutrients = get_current_nutrients(entries)
    goal_nutrients = get_goal_nutrients
    remaining_nutrients = get_remaining_nutrients(current_nutrients, goal_nutrients)
    {:current_nutrients => current_nutrients, :goal_nutrients => goal_nutrients, :remaining_nutrients => remaining_nutrients, :entries => entries}
  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

    def password_changed?
      password.present? or password_digest.blank?
    end

  def fatsecret_api_call(params)
    token = self.api_tokens.find_by_provider('fatsecret')
    response = Fatsecret::Api.new({}).api_call(
        ENV['FATSECRET_KEY'],
        ENV['FATSECRET_SECRET'],
        params,
        token['auth_token'] ||= "",
        token['auth_secret'] ||= ""
    )
    response.body
  end

  def sanitize_response(response)
    entries = JSON.parse(response).to_hash["food_entries"]["food_entry"]
    entries.each do |entry|
      entry.select! {|key, value| ((NUTRIENTS + ["food_entry_description"]).include?(key))}
    end
  end

     def get_current_nutrients(entries)
      Hash[NUTRIENTS.zip(NUTRIENTS.collect {|nutrient| entries.inject(0.0) {|total, match| total + match[nutrient].to_f}.round(1)})]
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
