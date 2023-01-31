public without sharing class SavedVehicleDao {
    
    public static List<Saved_Vehicle_for_Account__c> getSavedVehicleForAccountByAccountId(String accountId, String brand) {
        
        List < Saved_Vehicle_for_Account__c > queryResults = [Select
                                                              Id
                                                              ,Name
                                                              ,Saved_Vehicle__c
                                                              ,Saved_Vehicle__r.Name
                                                              ,Saved_Vehicle__r.Local_price__c
                                                              ,Saved_Vehicle__r.Order_Number__c
                                                              ,Saved_Vehicle__r.Account.billingCity
                                                              ,Saved_Vehicle__r.Previous_price__c
                                                              ,Saved_Vehicle__r.Is_Available_on_Website__c
                                                              ,Saved_Vehicle__r.Product2.Registration_Year_Alternative__c
                                                              ,Saved_Vehicle__r.Product2.Model_Year_Alternative__c
                                                              ,Saved_Vehicle__r.mileage__c
                                                              ,Saved_Vehicle__r.APO__c
                                                              ,Saved_Vehicle__r.New_Display__c 
                                                              ,Saved_Vehicle__r.APO_Display__c
                                                              ,Saved_Vehicle__r.Vehicle_Initial_Registration_Date__c
                                                              ,Saved_Vehicle__r.Vehicle_Image_L__c
                                                              ,Saved_Vehicle__r.Pictures__c // Added by RT --
                                                              ,toLabel(Saved_Vehicle__r.Product2.BodyStyle_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Product2.APO_Body_Style_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Product2.Model_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Product2.Specification_Pack_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Product2.Fuel_Type_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Product2.Transmission_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Product2.Engine_Capacity_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Product2.Wheel_Driven_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Product2.Power_Output_Alternative__c)
                                                              ,toLabel(Saved_Vehicle__r.Options__c)
                                                              ,toLabel(Saved_Vehicle__r.Exterior_Colour__c)
                                                              ,toLabel(Saved_Vehicle__r.Interior_Color__c)
                                                              
                                                              From Saved_Vehicle_for_Account__c
                                                              Where Account__c = :Accountid
                                                              And Saved_Vehicle__r.product2.Make__r.name = :brand
                                                              And Saved_Vehicle__r.Approved_On_Udaan__c = true
                                                              /*And (
                                                                  (Saved_Vehicle__r.New_Display__c = true And Saved_Vehicle__r.APO__c = false) 
                                                                  OR 
                                                                  (Saved_Vehicle__r.APO_Display__c = true And Saved_Vehicle__r.APO__c = true)
                                                              )*/
                                                              Order By LastModifiedDate Desc];
        
        
        List < Saved_Vehicle_for_Account__c > accountVehicles = new List < Saved_Vehicle_for_Account__c > ();
        if(queryResults != null && !queryResults.isEmpty()) {
            for(Saved_Vehicle_for_Account__c tempObj: queryResults) {
                if(tempObj.Saved_Vehicle__r.New_Display__c == true && tempObj.Saved_Vehicle__r.APO__c == false) { 
                    accountVehicles.add(tempObj); 
                }
                if(tempObj.Saved_Vehicle__r.APO_Display__c == true && tempObj.Saved_Vehicle__r.APO__c == true) { 
                    accountVehicles.add(tempObj); 
                }
            } 
        }
        return accountVehicles;		
    }
    
    
    public static List<Saved_Vehicle_for_Lead__c> getSavedVehicleForLeadByAccountId(String accountId, String brand) {
        
        List < Saved_Vehicle_for_Lead__c > queryResults = [Select
                                                           Id
                                                           ,Name
                                                           ,Saved_Vehicle__c
                                                           ,Saved_Vehicle__r.Name
                                                           ,Saved_Vehicle__r.Local_price__c
                                                           ,Saved_Vehicle__r.Order_Number__c
                                                           ,Saved_Vehicle__r.Previous_price__c
                                                           ,Saved_Vehicle__r.Is_Available_on_Website__c
                                                           ,Saved_Vehicle__r.Product2.Registration_Year_Alternative__c
                                                           ,Saved_Vehicle__r.Product2.Model_Year_Alternative__c
                                                           ,Saved_Vehicle__r.mileage__c
                                                           ,Saved_Vehicle__r.APO__c
                                                           ,Saved_Vehicle__r.New_Display__c
                                                           ,Saved_Vehicle__r.APO_Display__c
                                                           ,Saved_Vehicle__r.Vehicle_Initial_Registration_Date__c
                                                           ,Saved_Vehicle__r.Vehicle_Image_L__c
                                                           ,Saved_Vehicle__r.Pictures__c // Added by RT --
                                                           ,toLabel(Saved_Vehicle__r.Product2.BodyStyle_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Product2.APO_Body_Style_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Product2.Model_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Product2.Specification_Pack_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Product2.Fuel_Type_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Product2.Transmission_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Product2.Engine_Capacity_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Product2.Wheel_Driven_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Product2.Power_Output_Alternative__c)
                                                           ,toLabel(Saved_Vehicle__r.Options__c)
                                                           ,toLabel(Saved_Vehicle__r.Exterior_Colour__c)
                                                           ,toLabel(Saved_Vehicle__r.Interior_Color__c)
                                                           
                                                           From Saved_Vehicle_for_Lead__c
                                                           Where Lead__r.Account__c = :accountId
                                                           And Country_ISO_Code__c != 'BR'
                                                           And Saved_Vehicle__r.Product2.Make__r.Name = :brand
                                                           And Saved_Vehicle__r.Approved_On_Udaan__c = true
                                                           /*And (
                                                                (Saved_Vehicle__r.New_Display__c = true And Saved_Vehicle__r.APO__c = false) 
                                                                OR 
                                                                (Saved_Vehicle__r.APO_Display__c = true And Saved_Vehicle__r.APO__c = true)
                                                            )*/
                                                           Order By LastModifiedDate Desc];
        
        List < Saved_Vehicle_for_Lead__c > leadVehicles = new List < Saved_Vehicle_for_Lead__c > (); 
        if(queryResults != null && !queryResults.isEmpty()) {
            for(Saved_Vehicle_for_Lead__c tempObj: queryResults) {
                if(tempObj.Saved_Vehicle__r.New_Display__c == true && tempObj.Saved_Vehicle__r.APO__c == false) { 
                    leadVehicles.add(tempObj); 
                }
                if(tempObj.Saved_Vehicle__r.APO_Display__c == true && tempObj.Saved_Vehicle__r.APO__c == true) { 
                    leadVehicles.add(tempObj); 
                }
            } 
        }
        return leadVehicles;
    }
}