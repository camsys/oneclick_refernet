FactoryGirl.define do
  factory :category, class: OneclickRefernet::Category do
    sequence(:name) { |i| "Test Category #{i}" }
  end
  
  trait :recursive do
    after(:create) do |cat|
      cat.sub_categories << create(:sub_category, :recursive)
      cat.sub_categories << create(:sub_category, :recursive)
      cat.sub_categories << create(:sub_category, :recursive)
    end
  end
end
