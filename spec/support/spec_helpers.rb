module OneclickRefernet
  module SpecHelpers

    # Returns an appropriate factory name symbol from a class
    def factory_from_class(c)
      c.to_s.underscore
      .gsub("oneclick_refernet/","").to_sym
    end

    # Stubs out RefernetService class with fake API responses
    def stub_refernet_service(*methods)
      
      # Categories
      allow_any_instance_of(RefernetService)
      .to receive(:get_categories)
      .and_return(REFERNET_RESPONSES[:categories])
      
      # SubCategories
      allow_any_instance_of(RefernetService)
      .to receive(:get_sub_categories)
      .with("Test Category")
      .and_return(REFERNET_RESPONSES[:sub_categories])

      # SubSubCategories
      allow_any_instance_of(RefernetService)
      .to receive(:get_sub_sub_categories)
      .with(999)
      .and_return(REFERNET_RESPONSES[:sub_sub_categories])

      # Services
      allow_any_instance_of(RefernetService)
      .to receive(:get_services_by_category_and_county)
      .with("Test SubSubCategory")
      .and_return(REFERNET_RESPONSES[:services])
      
    end



    # Hash of sample responses from ReferNET
    REFERNET_RESPONSES = {
      categories: [
        {"Category_Name"=>"Housing", "Sequence_Nbr"=>1}, 
        {"Category_Name"=>"Financial Aid, Clothing and Material Goods", "Sequence_Nbr"=>7}, 
        {"Category_Name"=>"Food and Transportation", "Sequence_Nbr"=>9}
      ],
      sub_categories: [
        {"Subcategory_Name"=>"Crisis Hotlines", "Category_ID"=>773, "Sequence_Nbr"=>1}, 
        {"Subcategory_Name"=>"Mental Health Care Services", "Category_ID"=>774, "Sequence_Nbr"=>2}, 
        {"Subcategory_Name"=>"Substance Abuse Treatment Services", "Category_ID"=>778, "Sequence_Nbr"=>3}, 
        {"Subcategory_Name"=>"Counseling Services", "Category_ID"=>775, "Sequence_Nbr"=>4}
      ],
      sub_sub_categories: [
        {"Name"=>"Alcohol Use Related Hotlines"}, 
        {"Name"=>"Crisis Pregnancy Hotlines"}, 
        {"Name"=>"Domestic Violence Hotlines"}, 
        {"Name"=>"Drug Use Related Hotlines"}, 
        {"Name"=>"General Crisis Intervention Hotlines"}
      ],
      services: [
        {
          "Name_Agency"=>"BOYS TOWN NATIONAL HOTLINE", 
          "Name_Site"=>"BOYS TOWN NATIONAL HOTLINE", 
          "Address1"=>"Online/ Telephone Resource", 
          "Address2"=>nil, 
          "BldgLine"=>nil, 
          "City"=>"Boys Town", 
          "ZipCode"=>"68010", 
          "State"=>"NE", 
          "County"=>"Douglas", 
          "Number_Phone1"=>nil, 
          "Extension_Phone1"=>nil, 
          "Note_Phone1"=>nil, 
          "Type_Phone1"=>nil, 
          "Number_Phone2"=>nil, 
          "Extension_Phone2"=>nil, 
          "Note_Phone2"=>nil, 
          "Type_Phone2"=>nil, 
          "Number_Phone3"=>nil, 
          "Extension_Phone3"=>nil, 
          "Note_Phone3"=>nil, 
          "Type_Phone3"=>nil, 
          "Note1"=>"24/7 hotline for children and families experiencing crisis", 
          "Note1_CoNf"=>false, 
          "Note2"=>nil, 
          "Note2_CoNf"=>false, 
          "email"=>nil, 
          "url"=>nil, 
          "PEmail"=>nil, 
          "PUrl"=>nil, 
          "LEmail"=>"helpkids@boystown.org", 
          "LUrl"=>"http://www.boystown.org", 
          "ServiceGroup"=>"INFORMATION AND REFERRAL SERVICES", 
          "Program1"=>nil, 
          "Agency_Key"=>"211C69816", 
          "Site_Key"=>1, 
          "Service_ID"=>42286, 
          "Location_ID"=>69817, 
          "ServiceSite_ID"=>330161, 
          "MLPriority"=>1, 
          "Distance"=>0, 
          "InCity"=>"0", 
          "InZIP"=>"0", 
          "Record_Owner"=>"211C", 
          "Latitude"=>"41.259761", 
          "Longitude"=>"96.128888"
        }
      ]     
    }

  end
end
