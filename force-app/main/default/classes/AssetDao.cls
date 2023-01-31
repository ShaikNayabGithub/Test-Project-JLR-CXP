public without sharing class AssetDao {

    public static List<Asset> getAssetById(String assetId){
        return [Select
                    Id
                    ,VIN__c
                    ,MOT_Expiry__c
                    ,additional_registration_fee__c
                    ,open_market_value__c
                    ,certificate_of_entitlement__c
                    ,Link_for_detail_page_on_DX__c
                    ,Link_for_used_car_page_on_DX__c
                    ,Link_for_finance_page_on_DX__c
                    ,Is_Available_on_Website__c
                    ,Vehicle_Image_L__c
                    ,Vehicle_Image_M__c
                    ,Manufacture_Year__c
                    ,Number_IMS_Owners__c
                    ,Vehicle_interior_image_M__c
                    ,Vehicle_interior_image_L__c
                    ,Images__c
                    ,pictures__c
                    ,Local_price__c
                    ,Previous_price__c
                    ,ToLabel(Options__c)
                    ,ToLabel(Exterior_Colour__c)
                    ,ToLabel(Interior_Color__c)
                    ,Price
                    ,Monthly_Price__c
                    ,Model__c
                    ,mileage__c
                    ,Features_Base__c 
                    ,Features_Local__c//addedby sfurti
                    ,Order_Number__c // adddedby Ankita for Thank you page.
                    ,Vehicle_Initial_Registration_Date__c
                    ,Warranty_Start_Date__c // COSA-572
                    ,Product2.Make__r.name
                    ,Product2.Registration_Year_Alternative__c
                    ,Product2.Monthly_Price_From__c
                    ,Product2.Previous_Monthly_Price_From__c
                    ,ToLabel(Product2.Model_Year_Alternative__c)
                    ,Account.Email_used_for_Udaan__c
                    ,Account.Name
                    ,Account.NameLocal
                    ,Account.Address_Local__c
                    ,Account.City_Name_Local__c
                    ,Account.BillingCity
                    ,Account.BillingState
                    ,Account.BillingStreet
                    ,Account.BillingCountry
                    ,Account.BillingPostalCode
                    ,Account.Phone
                    ,AccountId
                    ,Account.LegalEntityID__c
                    ,Account.Local_Market_ID__c
                    ,Account.Website
                    ,ToLabel(Product2.APO_Body_Style_Alternative__c)
                    ,ToLabel(Product2.BodyStyle_Alternative__c)
                    ,ToLabel(Product2.Model_Alternative__c)
                    ,ToLabel(Product2.Specification_Pack_Alternative__c)
                    ,ToLabel(Product2.Fuel_Type_Alternative__c)
                    ,ToLabel(Product2.Transmission_Alternative__c)
                    ,ToLabel(Product2.Engine_Capacity_Alternative__c)
                    ,ToLabel(Product2.Engine_Name_Alternative__c )
                    ,ToLabel(Product2.Wheel_Driven_Alternative__c)
                    ,ToLabel(Product2.Power_Output_Alternative__c )
                    ,Derivative__r.Local_Market_Code__c
                    ,Product2.Name
                    ,Product2.ProductCode
                    
                   
                From
                    Asset
                where
                    Id =: assetId]; 
    }
    
  
    public static List<Asset> getNearMatchAssets(String selectedModel, Decimal selectedPrice, String market, Boolean isAPO){
        List<Asset> resultList = new List<Asset>();
        String soql =       'Select '
                                + 'Id '
                                + ',additional_registration_fee__c '
                                + ',open_market_value__c '
                                + ',Manufacture_Year__c'
                                + ',certificate_of_entitlement__c '
                                + ',Link_for_detail_page_on_DX__c '
                                + ',Link_for_used_car_page_on_DX__c '
                                + ',Link_for_finance_page_on_DX__c'
                                + ',Is_Available_on_Website__c '
                                + ',Vehicle_Image_L__c,Vehicle_Image_M__c '
                                + ',Vehicle_interior_image_M__c '
                                + ',Vehicle_interior_image_L__c '
                                + ',Number_IMS_Owners__c'
                                + ',Images__c '
                                + ',APO__c'
                                + ',Price '
                                + ',Monthly_Price__c '
                                + ',Local_price__c '
                                + ',Previous_price__c'
                                + ',Model__c '
                                + ',mileage__c '
                                + ',Vehicle_Initial_Registration_Date__c '
                                + ',Warranty_Start_Date__c '
                                + ',Order_Number__c'
                                + ',VIN__c '
                                + ',MOT_Expiry__c'
                                + ',Pictures__c '
                                + ',Account.Name'
                                + ',Account.NameLocal '
                                + ',Account.Address_local__c '
                                + ',Account.City_Name_Local__c'
                                + ',Account.Phone '
                                + ',Account.Website'
                                + ',Account.Email_used_for_Udaan__c '
                                + ',Account.BillingCity '
                                + ',Account.BillingState '
                                + ',ToLabel(Options__c) '
                                + ',ToLabel(Exterior_Colour__c) '
                                + ',ToLabel(Interior_Color__c) '
                                + ',Product2.Make__r.name '
                                + ',Product2.Monthly_Price_From__c'
                                + ',Product2.Previous_Monthly_Price_From__c'
                                + ',Product2.Registration_Year_Alternative__c' 
                                + ',ToLabel(Product2.Model_Year_Alternative__c)' 
                                + ',ToLabel(Product2.BodyStyle_Alternative__c) '
                                + ',ToLabel(Product2.APO_Body_Style_Alternative__c) '
                                + ',ToLabel(Product2.Model_Alternative__c) '
                                + ',ToLabel(Product2.Specification_Pack_Alternative__c) '
                                + ',ToLabel(Product2.Fuel_Type_Alternative__c) '
                                + ',ToLabel(Product2.Transmission_Alternative__c) '
                                + ',ToLabel(Product2.Engine_Capacity_Alternative__c) '
                                + ',ToLabel(Product2.Engine_Name_Alternative__c) '
                                + ',ToLabel(Product2.Wheel_Driven_Alternative__c) '
                                + ',ToLabel(Product2.Power_Output_Alternative__c ) '
                                
                            + 'From '
                                + 'Asset '
                            + 'Where '
                              //+ 'Model__c = :selectedModel '
                                + 'Product2.Model_Alternative__c = :selectedModel '
                            + 'And '
                                + 'Approved_On_Udaan__c = true and Account.Country_ISO_Code__c = :market ';
                            if(isAPO == true)
                                {
                                    soql += 'and APO__c = :isAPO and APO_Display__c = true ';
                                }
                            if(isAPO == false)
                                {
                                    soql += 'and APO__c = :isAPO and New_Display__c = true ';
                                }
        
        String upper3Soql =   'And '
                                + 'Local_price__c >=:selectedPrice '
                            + 'Order By '
                                + 'Local_price__c Asc '
                            + 'Limit 3';
        
        String lower2Soql =   'And '
                                + 'Local_price__c < :selectedPrice '
                            + 'Order By '
                                + 'Local_price__c Desc '
                            + 'Limit 2';
        List<Asset> lowerList = (List<Asset>)Database.query(soql + lower2Soql);
        for(Integer i = lowerList.size()-1; i >= 0; i--){
            resultList.add(lowerList.get(i));
        }
        String mystr = soql + lower2Soql;
        system.debug('---soql:' + mystr);
         system.debug('---soql:' + selectedModel + '/' + market);
        system.debug('---match:' + resultList);
        resultList.addAll( (List<Asset>)Database.query(soql + upper3Soql) );
        system.debug('---soql 2:' + soql + upper3Soql);
        system.debug('----final list:' + resultList);
        return resultList;
    }
     public static List<Asset> getAssetForCompareById(String assetId){
        return [Select
                    Id
                    ,Name
                    ,Model_Year__c
                    ,ToLabel(Transmission__c)
                    ,ToLabel(Body_Style__c)
                    ,ToLabel(Engine__c)
                    ,ToLabel(Fuel_Type__c)
                    ,Is_Available_on_Website__c
                    ,Vehicle_Image_L__c
                    ,Vehicle_Image_M__c
                    ,Vehicle_interior_image_M__c
                    ,Vehicle_interior_image_L__c
                    ,Images__c
                    ,pictures__c
                    ,Local_price__c
                    ,Previous_price__c
                    ,ToLabel(Options__c)
                    ,ToLabel(Exterior_Colour__c)
                    ,ToLabel(Interior_Color__c)
                    ,Price
                    ,Monthly_Price__c
                    ,Model__c
                    ,mileage__c
                    ,Features_Base__c 
                    ,Features_Local__c//addedby sfurti
                    ,Vehicle_Initial_Registration_Date__c
                    ,Warranty_Start_Date__c // COSA-572                
                    ,Account.NameLocal
                    ,Account.Name
                    ,Account.Address_local__c
                    ,Account.Phone
                    ,ToLabel(Product2.APO_Body_Style_Alternative__c) 
                    ,ToLabel(Product2.BodyStyle_Alternative__c)
                    ,ToLabel(Product2.Model_Alternative__c)
                    ,ToLabel(Product2.Specification_Pack_Alternative__c)
                    ,ToLabel(Product2.Fuel_Type_Alternative__c)
                    ,ToLabel(Product2.Transmission_Alternative__c)
                    ,ToLabel(Product2.Engine_Capacity_Alternative__c)
                    ,ToLabel(Product2.Engine_Name_Alternative__c )
                    ,ToLabel(Product2.Wheel_Driven_Alternative__c)
                    ,ToLabel(Product2.Power_Output_Alternative__c )
                    ,Product2.Registration_Year_Alternative__c
                    ,Product2.Monthly_Price_From__c
                    ,Product2.Previous_Monthly_Price_From__c
                    ,ToLabel(Product2.Model_Year_Alternative__c)  
                From
                    Asset
                where
                    Id =: assetId]; 
    }
    
    
}