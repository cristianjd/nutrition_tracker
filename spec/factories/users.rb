# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    username "MyString"
    password_digest "MyString"
    calories "9.99"
    protein_ratio "9.99"
    carbohydrate_ratio "9.99"
    fat_ratio "MyString"
  end
end
