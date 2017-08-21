FactoryGirl.define do
  factory :sub_category, class: OneclickRefernet::SubCategory do
    name "Test SubCategory"
    
    trait :with_category do
      category
    end
  end
end
