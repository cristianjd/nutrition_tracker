class ApiToken < ActiveRecord::Base
  belongs_to :user
  attr_accessible :auth_secret, :auth_token, :provider, :user_id
end
