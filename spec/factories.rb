FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
  end
  
  factory :category do
    name "the category"
    user
  end
end