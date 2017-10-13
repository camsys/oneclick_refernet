FactoryGirl.define do
  factory :sub_sub_category, class: OneclickRefernet::SubSubCategory do
    sequence(:name) { |i| "Test SubSubCategory #{i}" }
    
    trait :with_sub_category do
      sub_category { create(:sub_category, :with_category) }
    end
    
    trait :with_services do
      after(:create) do |ssc|
        ssc.services << create(:service)
        ssc.services << create(:service)
        ssc.services << create(:service)
      end
    end
    
    trait :recursive do
      with_services
    end
    
    # Create a translation for this subsubcategory
    after(:create) do |ssc|
      ssc.set_translated_name(ssc.name)
    end
    
  end
end
