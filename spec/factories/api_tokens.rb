# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_token do
    auth_token "MyString"
    auth_secret "MyString"
    provider "MyString"
    user_id 1
  end
end
