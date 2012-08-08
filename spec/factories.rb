FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    password_confirmation "foobar"
  end
  
  factory :category do
    name "the category"
    user
  end
  
  factory :transaction do
    sequence(:description)  { |n| "Description #{n}" }
    date { rand(100.days).ago }
    amount { 1 + rand(100) }
    is_debit true
    category
    user
  end
end