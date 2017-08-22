FactoryGirl.define do
  factory :service, class: OneclickRefernet::Service do
    sequence(:agency_name) { |i| "Test Agency Name #{i}" }
    sequence(:site_name) { |i| "Test Site Name #{i}" }
    details { {
      "Name_Agency" => "Test Agency Name",
      "Name_Site" => "Test Site Name",
      "otherDetails" => "blahblahblah",
      "Latitude" => "28.0",
      "Longitude" => "82.0"
    } }
    latlng { RGeo::Geos::CAPIFactory.new(:srid => 4326).point(28.0, -82.0) }
    
    trait :with_sub_sub_categories do
      after(:create) do |svc|
        svc.sub_sub_categories << create(:sub_sub_category)
        svc.sub_sub_categories << create(:sub_sub_category)
      end
    end
  end
end
