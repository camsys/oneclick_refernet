FactoryGirl.define do
  factory :service, class: OneclickRefernet::Service do
    agency_name "Test Agency Name"
    site_name "Test Site Name"
    details { {
      "Name_Agency" => "Test Agency Name",
      "Name_Site" => "Test Site Name",
      "otherDetails" => "blahblahblah",
      "Latitude" => "28.0",
      "Longitude" => "82.0"
    } }
    latlng { RGeo::Geos::CAPIFactory.new(:srid => 4326).point(28.0, -82.0) }
    
    trait :with_sub_sub_categories do
      after(:create) do
      end
    end
  end
end
