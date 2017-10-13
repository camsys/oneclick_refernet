FactoryGirl.define do
  factory :category, class: OneclickRefernet::Category do
    sequence(:name) { |i| "Test Category #{i}" }
  end
  
  trait :with_sub_categories do
    after(:create) do |cat|
      cat.sub_categories << create(:sub_category)
      cat.sub_categories << create(:sub_category)
      cat.sub_categories << create(:sub_category)
    end
  end
  
  trait :recursive do
    after(:create) do |cat|
      cat.sub_categories << create(:sub_category, :recursive)
      cat.sub_categories << create(:sub_category, :recursive)
      cat.sub_categories << create(:sub_category, :recursive)
    end
  end
  
  # Create a translation for this category
  after(:create) do |cat|
    cat.set_translated_name(cat.name) if cat.class == OneclickRefernet::Category
  end
  
end
