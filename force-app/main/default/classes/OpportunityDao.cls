/*
  TCRM-3766: Saved quote data being deleted after 7 days if Retailer doesn't update 'Status'
*/
public without sharing class OpportunityDao {
    public static List<Opportunity> getSaveQuotes(String accountId, String brand){
        return [Select
                    id
                    ,name
                    ,Local_deposit_amount__c
                    ,Local_Bonus_Payment_Amount__c
                    ,Local_vehicle_price__c
                    ,Trade_In__c
                    ,Trade_in_vehicle__c
                    ,Local_monthly_Payment_Amount__c
                    ,Number_of_bonus__c
                    ,Trade_In_Value__c 
                    ,Local_loan_amount__c
                    ,Interest_rate__c
                    ,Local_total_paid_amount__c
                    ,Number_of_monthly_payment__c
                    ,Local_interest_charge__c
                    ,Selected_finance_option__c
                    ,Quote_saved_date__c
                    ,First_Payment__c
                    ,Final_Payment__c
                    ,Finance_TradeinValue__c
                    ,Asset__c
                    ,Asset__r.Id
                    ,Asset__r.Name
                    ,Asset__r.Is_Available_on_Website__c
                    ,Asset__r.Local_price__c
                    ,Asset__r.Previous_price__c
                    ,Asset__r.Product2.Registration_Year_Alternative__c
                    ,Asset__r.Product2.Model_Year_Alternative__c
                    ,Asset__r.Engine__c
                    ,Asset__r.Exterior_Detail_Color_Image__c
                    ,Asset__r.Exterior_Colour_Group__c
                    ,Asset__r.Specification_Key_Text__c
                    ,Asset__r.Asset_Specification_Pack__c
                    ,Asset__r.Asset_Detail_Specification_Pack__c
                    ,Asset__r.Specification_Image_1__c
                    ,Asset__r.Specification_Image_2__c
                    ,Asset__r.Specification_Image_3__c
                    ,Asset__r.Specification_Key__c
                    ,Asset__r.Interior_Color_Image__c
                    ,Asset__r.Search_Key__c
                    ,Asset__r.Search_Key_Text__c
                    ,Asset__r.Body_Style_Key_Text__c
                    ,Asset__r.Vehicle_Image_L__c
                    ,Asset__r.Master_Colour__c
                    ,Asset__r.Model__c
                    ,Asset__r.Colour__c
                    ,Asset__r.APO__c
                    ,Asset__r.Pictures__c
                    
                    ,Asset__r.Exterior_Colour_Code__c
                    ,Asset__r.Body_Style_Image_M__c
                    ,Asset__r.Name_Plate__c
                    ,Asset__r.Body_Style__c
                    ,Asset__r.Engine_Number__c
                    ,Asset__r.Price
                	,Asset__r.Account.billingCity
                    ,Retailer__r.Address_local__c
                    ,Retailer__r.NameLocal
                    ,Retailer__r.BillingStreet
                    ,Retailer__r.BillingCity
                    ,Retailer__r.BillingState
                    ,Retailer__r.BillingPostalCode
                    ,Retailer__r.BillingCountry
                    ,Retailer__r.BillingLatitude
                    ,Retailer__r.BillingLongitude
                    ,Retailer__r.Phone
                    ,toLabel(Asset__r.Product2.BodyStyle_Alternative__c)
                    ,toLabel(Asset__r.Product2.APO_Body_Style_Alternative__c) // -- Added by RT --
                    ,ToLabel(Asset__r.Product2.Model_Alternative__c)
                    ,ToLabel(Asset__r.Product2.Specification_Pack_Alternative__c)
                    ,ToLabel(Asset__r.Product2.Fuel_Type_Alternative__c)
                    ,ToLabel(Asset__r.Product2.Transmission_Alternative__c)
                    ,ToLabel(Asset__r.Product2.Engine_Capacity_Alternative__c)
                    ,ToLabel(Asset__r.Product2.Wheel_Driven_Alternative__c)
                    ,toLabel(Asset__r.Product2.Power_Output_Alternative__c)
                    ,ToLabel(Asset__r.Options__c)
                    ,ToLabel(Asset__r.Transmission__c)
                    ,ToLabel(Asset__r.Fuel_Type__c)
                    ,ToLabel(Asset__r.Interior_Color__c)
                    ,ToLabel(Asset__r.Exterior_Colour__c)
                From
                    Opportunity
                Where
                    AccountId = :accountId
                And
                    StageName = 'Save a Quote'
                And
                    Asset__r.Approved_On_Udaan__c = true
                And
                   ((Asset__r.New_Display__c = true And Asset__r.APO__c = false) 
                    OR 
                   (Asset__r.APO_Display__c = true And Asset__r.APO__c = true))
                And
                    Asset__r.Product2.Make__r.Name = :brand
                And // Changes for TCRM-3766 starts
                    Quote_Expired__c = false
                // Changes for TCRM-3766 stop
                Order By
                    LastModifiedDate Desc
                ];
    }
    
    public static List<Opportunity> getReserve(String accountId, String brand){
        return [Select
                    Id
                    ,Account.Preferred_Sales_Retailer__r.NameLocal
                    ,Account.Preferred_Sales_Retailer__r.Retailer_Address__c
                    ,name
                    ,Trade_In__c
                    ,Trade_in_vehicle__c
                    ,Local_deposit_amount__c
                    ,Local_monthly_Payment_Amount__c
                    ,First_Payment__c,Final_Payment__c
                    ,Trade_In_Value__c 
                    ,Local_loan_amount__c
                    ,Interest_rate__c
                    ,Local_total_paid_amount__c
                    ,Deposit_paid_date__c
                    ,Local_Bonus_Payment_Amount__c
                    ,Number_of_bonus__c
                    ,Local_vehicle_price__c
                    ,Number_of_monthly_payment__c
                    ,Local_interest_charge__c
                    ,Selected_finance_option__c
                    ,Finance_TradeinValue__c
                    ,Asset__c
                    ,Asset__r.Product2.Specification_Pack_Alternative__c
                    ,Asset__r.Product2.Registration_Year_Alternative__c
                	,Asset__r.Product2.Model_Year_Alternative__c
                    ,Asset__r.Local_price__c
                    ,Asset__r.Previous_price__c
                    ,Asset__r.price
                    ,Asset__r.Order_Number__c
                    ,Asset__r.Vehicle_Image_L__c
                    ,Asset__r.Pictures__c
                    ,Asset__r.Id
                	,Asset__r.APO__c
                    ,Asset__r.VIN__c 
                    ,Asset__r.Is_Available_on_Website__c
                    ,Retailer__r.Address_local__c
                    ,Retailer__r.NameLocal
                    ,Retailer__r.BillingStreet
                    ,Retailer__r.BillingCity
                    ,Retailer__r.BillingState
                    ,Retailer__r.BillingPostalCode
                    ,Retailer__r.BillingCountry
                    ,Retailer__r.BillingLatitude
                    ,Retailer__r.BillingLongitude
                    ,Retailer__r.Phone
                    ,toLabel(Asset__r.Product2.BodyStyle_Alternative__c)
                    ,toLabel(Asset__r.Product2.APO_Body_Style_Alternative__c) // -- Added by RT --
                    ,toLabel(Asset__r.Product2.Fuel_Type_Alternative__c) 
                    ,toLabel(Asset__r.Product2.Transmission_Alternative__c)
                    ,toLabel(Asset__r.Product2.Engine_Capacity_Alternative__c)
                    ,toLabel(Asset__r.Product2.Wheel_Driven_Alternative__c)
                    ,toLabel(Asset__r.Product2.Model_Alternative__c)
                    ,toLabel(Asset__r.Product2.Power_Output_Alternative__c)
                    ,toLabel(Asset__r.Exterior_Colour__c)
                    ,toLabel(Asset__r.Interior_Color__c)
                    ,toLabel(Asset__r.Options__c)
                From
                    Opportunity
                Where
                    AccountId = :accountId
                And
                    StageName = 'Pay Deposit'
                And
                    Asset__r.Product2.Make__r.name = :brand
                Order By
                    LastModifiedDate Desc
                ];
    }
}