FactoryGirl.define do
  factory :sub_category, class: OneclickRefernet::SubCategory do
    sequence(:name) { |i| "Test SubCategory #{i}" }
    sequence(:refernet_category_id) { |i| i + 700 }
    
    trait :with_category do
      category
    end
    
    trait :with_sub_sub_categories do
      after(:create) do |sub_cat|
        sub_cat.sub_sub_categories << create(:sub_sub_category)
        sub_cat.sub_sub_categories << create(:sub_sub_category)
        sub_cat.sub_sub_categories << create(:sub_sub_category)
      end
    end
    
    trait :recursive do
      after(:create) do |sub_cat|
        sub_cat.sub_sub_categories << create(:sub_sub_category, :recursive)
        sub_cat.sub_sub_categories << create(:sub_sub_category, :recursive)
        sub_cat.sub_sub_categories << create(:sub_sub_category, :recursive)
      end
    end
  end
end
