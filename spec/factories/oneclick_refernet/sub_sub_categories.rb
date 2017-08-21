FactoryGirl.define do
  factory :sub_sub_category, class: OneclickRefernet::SubSubCategory do
    name "Test SubSubCategory"
    
    trait :with_sub_category do
      sub_category { create(:sub_category, :with_category) }
    end
  end
end
