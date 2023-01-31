public class Account_Secondary_Account_Creator {
    
    
    
    
    public void createclonedSecondary(List<Account> accs){
        
        Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        List<Account> individuals = new List<Account>();
        List<Account> corporates = new List<Account>();
        
        For(Account acc : accs){
            if(acc.Recordtypeid == individualId){
                individuals.add(acc);
            }    
            
            if(acc.RecordtypeId == CorporateId){
                corporates.add(acc);
            }
            
        }
        
        if(!individuals.isEmpty() ){
            System.debug('Found Individuals: '+Json.serializePretty(individuals));
            // createForIndividual(individuals);
            copyDetails(individuals,true);
        }
        //todo corporate
        if(!corporates.isEmpty() ){
            System.debug('Found corporates: '+Json.serializePretty(corporates));
            //  createForCorportate(corporates);
            copyDetails(corporates,false);
        }
        
        
        
        
    }
    
    private void copyDetails(List<Account> accs, boolean personaccount){
        System.debug('Entered copyDetails');
        //get list of accounts primary
        //retrieve all parent details
        //map primary to account
        //Copy
        Set<Id> parentids = SObjectUtilities.GetFieldValuesId(accs,  'Primary_Account__c');
          Set<Id> Moreparentids = SObjectUtilities.GetFieldValuesId(accs,  'Primary_Account__pc');
        parentids.addAll(Moreparentids);
        System.debug('Got Parent Ids '+Json.serializePretty(parentids));
        //testing comment out below and use this       Map<Id,Account> primary = new Map<Id, Account>([SELECT Name, FirstName, LastName FROM Account where id in:parentids]);
        Map<Id,Account> primary = new Map<Id, Account>([SELECT Id, IsDeleted, MasterRecordId, Name, LastName, 
                                                        FirstName, Salutation, Type, RecordTypeId, ParentId, BillingStreet, 
                                                        BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, 
                                                        BillingLongitude, BillingGeocodeAccuracy, BillingAddress, 
                                                        ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, 
                                                        ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Phone,
                                                        Fax, AccountNumber, Website, PhotoUrl, Sic, Industry, AnnualRevenue, NumberOfEmployees, 
                                                        Ownership, TickerSymbol, Description, Rating, Site, CurrencyIsoCode, NameLocal, OwnerId,
                                                        CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, 
                                                        LastViewedDate, LastReferencedDate, IsExcludedFromRealign, IsPartner, IsCustomerPortal, 
                                                        PersonContactId, IsPersonAccount, ChannelProgramName, ChannelProgramLevelName, 
                                                        PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode,
                                                        PersonMailingCountry, PersonMailingLatitude, PersonMailingLongitude, PersonMailingGeocodeAccuracy, 
                                                        PersonMailingAddress, PersonOtherStreet, PersonOtherCity, PersonOtherState, PersonOtherPostalCode,
                                                        PersonOtherCountry, PersonOtherLatitude, PersonOtherLongitude, PersonOtherGeocodeAccuracy, PersonOtherAddress, 
                                                        PersonMobilePhone, PersonHomePhone, PersonOtherPhone, PersonAssistantPhone, PersonFirstNameLocal, 
                                                        PersonLastNameLocal, PersonEmail, PersonTitle, PersonDepartment, PersonAssistantName, PersonLeadSource, 
                                                        PersonBirthdate, PersonHasOptedOutOfEmail, PersonHasOptedOutOfFax, PersonDoNotCall, PersonLastCURequestDate,
                                                        PersonLastCUUpdateDate, PersonEmailBouncedReason, PersonEmailBouncedDate, PersonIndividualId, Jigsaw, 
                                                        JigsawCompanyId, AccountSource, SicDesc, Account_Rating__c, Account_Score__c, Alternative_Key__c, Body_Shop__c,
                                                        Brand__c, Business_Appointment_Last_Visited_Date__c, Company_Fleet_Size__c, 
                                                        DMS_Identifier__c, Dealer_CI_Code__c, LegalEntityID__c, Nominating_Retailer__c, 
                                                        Other_Brands__c, ParentRecord__c, Preferred_Sales_Retailer__c, Primary_Dealer_Code__c,
                                                        Queue_ID__c, Retailer_Status__c, Retailer_Type__c, Retailer__c, Secondary_Dealer_Code__c,
                                                        Service_Centre__c, Site__c, Started_Trading__c, Stopped_Trading__c, TimeLastSentToDMS__c, 
                                                        Trading_Name__c, Trading_Partner_Type__c, ntt_Jaguar_Status__c, ntt_Land_Rover_Status__c, 
                                                        Are_All_Preferences_Set__c, Confirm_Deceased__c, Deceased_Date__c, Retailer_Name__c, 
                                                        Country_ISO_Code__c, International_Account__c, Last_Selling_Retailer__c, Record_Sub_Type__c,
                                                        Dealer_CI_Code_2__c, NSC_Importer__c, Region_or_Market__c, Data_Quality_Description__c, 
                                                        Data_Quality_Score__c, Retailer_Email__c, LiveAgent_OptOut__c, Owner_Manager__c,
                                                        Customer_Journey_Stage__c, Next_Activity_Date__c, Last_Selling_Retailer_Local__c, Nominating_Retailer_Local__c,
                                                        Parent_Account_Local__c, Preferred_Sales_Retailer_Local__c, Pseudo_Account_Owner__c, MENA_Reference__c,
                                                        MENA_Reference2__c, Owned_by_Current_User__c, CPF__c, Owner_Dealer_CI_Code_2__c, Owner_Dealer_CI_Code__c,
                                                        Account_Type__c, Is_Primary__c, Parent_Retailer__c, Pass_Duplicate_Rule__c, Regional_State_Code__c, 
                                                        Select_Country_ISO_Code__c, Data_Enrichment_Priority_Effective_To__c, Data_Enrichment_Priority_Level__c,
                                                        Primary_Account__c, X17_LRE_Kochi__c, Account_Owner_Role__c, Pseudo_Account_Owner_Type__c, Person_Contact_ID__c,
                                                        Accounts__c, ADDRESS_2__c, ADDRESS_3__c, ADDRESS_4__c, Complete_Suppression__c, Employer_Company__c, 
                                                        Invoice_Number__c, Invoice_Value__c, Month_Year_of_Birth__c, Permissions_for_Contact__c, 
                                                        Preferred_Methods_of_Contact__c, SURNAME_2__c, Suppression_Direct_Mail__c, Suppression_Email__c, 
                                                        Suppression_Phone__c, USER_CHOOSER_OR_DRIVER__c, Email_used_for_Udaan__c, CustomerID__c, Address_local__c, 
                                                        Merchant_Id__c, Prefecture__c, Retailer_Address__c, Service_Id__c, Trade_In_Brand__c, Trade_in_Color__c,
                                                        Trade_in_Grade__c, Trade_in_Mileage__c, Trade_in_Model_Year__c, Trade_in_Model__c, Trade_in_Value__c, 
                                                        c_udaan_marketarea1__c, c_udaan_marketarea2__c, Incorrect_Address__c, Incorrect_Phone_Number__c, Incorrect_Email__c, 
                                                        After_Sales_Region__c, Sales_Region__c, Preferred_Service_Retailer__c, Opportunities_on_Account__c, JLR_Unique_Combination__c,
                                                        Number_of_Open_Cases__c, Corporate__c, Checked_for_Deletion__c, Has_Email_Phone_Address__c, Has_Email_Address__c, 
                                                        Has_Phone__c, Has_Email_OR_Phone__c, Has_Address_MX__c, Owner_Retailer__c, Loyalty_Scheme_Reference__c, Loyalty_Scheme__c,
                                                        SAP_ID__c, VITAL_Ref__c, Corporate_Programme_Code__c, Corporate_Code__c, Fleet_Manager__c, Fleet_Customer_Category__c, 
                                                        Fleet_purchasing_policy__c, Num_of_Management_Vehicles__c, Budget_Amount_per_Vehicle__c, Buyback__c, Buyback_Amount__c, 
                                                        Buyback_Percentage__c, Car_Allowance__c, Monthly_Amount__c, B2C_Type__c, Type_of_Rental__c, Financed__c, Additional_Finance__c,
                                                        Vehicle_Trade_In__c, Num_of_Vehicles_Traded_In__c, Mileage_per_Months_of_Vehicles_purchased__c, Type_of_Leasing__c, 
                                                        Embassy_Name__c, Vehicle_purchased_for__c, End_or_Service__c, Ministry_OR_Government_Department_Name__c, 
                                                        Vehicles_sourced_through_tender__c, Start_Date__c, End_Date__c, Term_Mileage__c, JLR_Department_Name__c, JLR_Location__c, 
                                                        Supplier_Vendor_Name__c, Group_Company_Name__c, Group_Company_Location__c, Is_Accounts_Not_Available_to_All__c, 
                                                        Is_PII_Data_Conflict__c, Create_Golden_Record__c, Create_Secondary_Account__c, et4ae5__HasOptedOutOfMobile__pc, 
                                                        et4ae5__Mobile_Country_Code__pc, Account_Queue_ID__pc, Address_Validation_Status__pc, Annual_Mileage__pc, 
                                                        Are_All_Preferences_Set__pc, Assistant_Name_Hidden__pc, Assistant_Phone_Hidden__pc, Confirm_Deceased__pc, DMS_Identifier__pc,
                                                        Deceased_Date__pc, Direct_Mail_Opt_Out__pc, Driving_Experience_Interests__pc, Email2__pc, Email3__pc,
                                                        Employment_Status__pc, Gender__pc, Guest_Name__pc, Household_Income__pc, Interests__pc, 
                                                        Jaguar_Gold_Starred_Date__pc, Jaguar_Gold_Starred__pc, Jaguar_Red_Flagged_Date__pc, 
                                                        Jaguar_Red_Flagged__pc, Land_Rover_Gold_Starred_Date__pc,
                                                        Land_Rover_Gold_Starred__pc, Land_Rover_Red_Flagged_Date__pc, 
                                                        Land_Rover_Red_Flagged__pc, Language__pc, Marital_Status__pc, 
                                                        Net_Worth__pc, No_of_Cars_In_Household__pc, No_of_Children__pc, No_of_People_In_Household__pc, Occupation__pc,
                                                        Other_Phone_Hidden__pc, Owners_Club_Requested__pc, Parent_Record__pc, Preferred_Contact_Time__pc, Retailer__pc, Site__pc, 
                                                        TimeLastSentToDMS__pc, Retailer_Name__pc, aop_Country__pc, Country_ISO_Code__pc, aop_Is_Qualified_for_Events__pc,
                                                        aop_Last_Qualifying_Event__pc, aop_Suspended_for_Events__pc, aop_Suspension_Reason__pc, aopcom_contactPortrait__pc,
                                                        Data_Quality_Description__pc, Data_Quality_Score__pc, Birthday__pc, Contact_Owner_Phone_Number__pc, Calculated_Email__pc,
                                                        Checked_for_Deletion__pc, Membership_Number__pc, Contact_Region_or_Market__pc, Likes_About_Current_Car__pc, 
                                                        Dislikes_About_Current_Car__pc, Essential_Use_of_the_Car__pc, Must_Have_Features__pc, No_of_Passengers__pc,
                                                        Space_and_Towing__pc, Usual_Method_of_Finance__pc, Trade_In_Valuation__pc, Next_Activity_Date__pc, 
                                                        Who_is_the_Main_Driver__pc, Who_Else_Will_be_Driving_the_Car__pc, Additional_Notes__pc, MENA_Reference__pc, 
                                                        Change_Current_Car_months__pc, MENA_Reference2__pc, Primary_Account__pc,
                                                        Birthdate_Hidden__pc, Account_Name_Local__pc, Account_Pseudo_Owner_Id__pc, Parent_Record_Local__pc,
                                                        Retailer_Local__pc, Translation_Language_Key__pc, FPACE_Marketing__pc, Pass_Duplicate_Rule__pc, Contacts__pc,
                                                        Number_of_Open_Cases__pc FROM Account where id in:parentids]);
        
        
        for(Account acc : accs){
            system.debug('Primaries '+primary);
            Account parent = primary.get(acc.Primary_Account__c);
            acc.Is_Primary__c = false;
            
            System.debug('Got parent'+parent.Id);
            if(personaccount){
                If(parent.FirstName != null){
                    acc.FirstName = parent.FirstName;
                }
                If(parent.LastName != null){
                    acc.LastName = parent.LastName;
                }
                if(parent.PersonMailingStreet != null ){  acc.PersonMailingStreet = parent.PersonMailingStreet; }
if(parent.PersonMailingCity != null ){  acc.PersonMailingCity = parent.PersonMailingCity; }
if(parent.PersonMailingState != null ){  acc.PersonMailingState = parent.PersonMailingState; }
if(parent.PersonMailingPostalCode != null ){  acc.PersonMailingPostalCode = parent.PersonMailingPostalCode; }
if(parent.PersonMailingCountry != null ){  acc.PersonMailingCountry = parent.PersonMailingCountry; }
if(parent.PersonMailingLatitude != null ){  acc.PersonMailingLatitude = parent.PersonMailingLatitude; }
if(parent.PersonMailingLongitude != null ){  acc.PersonMailingLongitude = parent.PersonMailingLongitude; }
if(parent.PersonMailingGeocodeAccuracy != null ){  acc.PersonMailingGeocodeAccuracy = parent.PersonMailingGeocodeAccuracy; }
if(parent.PersonOtherStreet != null ){  acc.PersonOtherStreet = parent.PersonOtherStreet; }
if(parent.PersonOtherCity != null ){  acc.PersonOtherCity = parent.PersonOtherCity; }
if(parent.PersonOtherState != null ){  acc.PersonOtherState = parent.PersonOtherState; }
if(parent.PersonOtherPostalCode != null ){  acc.PersonOtherPostalCode = parent.PersonOtherPostalCode; }
if(parent.PersonOtherCountry != null ){  acc.PersonOtherCountry = parent.PersonOtherCountry; }
if(parent.PersonOtherLatitude != null ){  acc.PersonOtherLatitude = parent.PersonOtherLatitude; }
if(parent.PersonOtherLongitude != null ){  acc.PersonOtherLongitude = parent.PersonOtherLongitude; }
if(parent.PersonOtherGeocodeAccuracy != null ){  acc.PersonOtherGeocodeAccuracy = parent.PersonOtherGeocodeAccuracy; }
if(parent.PersonMobilePhone != null ){  acc.PersonMobilePhone = parent.PersonMobilePhone; }
if(parent.PersonHomePhone != null ){  acc.PersonHomePhone = parent.PersonHomePhone; }
if(parent.PersonOtherPhone != null ){  acc.PersonOtherPhone = parent.PersonOtherPhone; }
if(parent.PersonAssistantPhone != null ){  acc.PersonAssistantPhone = parent.PersonAssistantPhone; }
if(parent.PersonFirstNameLocal != null ){  acc.PersonFirstNameLocal = parent.PersonFirstNameLocal; }
if(parent.PersonLastNameLocal != null ){  acc.PersonLastNameLocal = parent.PersonLastNameLocal; }
if(parent.PersonEmail != null ){  acc.PersonEmail = parent.PersonEmail; }
if(parent.PersonTitle != null ){  acc.PersonTitle = parent.PersonTitle; }
if(parent.PersonDepartment != null ){  acc.PersonDepartment = parent.PersonDepartment; }
if(parent.PersonAssistantName != null ){  acc.PersonAssistantName = parent.PersonAssistantName; }
if(parent.PersonLeadSource != null ){  acc.PersonLeadSource = parent.PersonLeadSource; }
if(parent.PersonBirthdate != null ){  acc.PersonBirthdate = parent.PersonBirthdate; }
if(parent.PersonHasOptedOutOfEmail != null ){  acc.PersonHasOptedOutOfEmail = parent.PersonHasOptedOutOfEmail; }
if(parent.PersonHasOptedOutOfFax != null ){  acc.PersonHasOptedOutOfFax = parent.PersonHasOptedOutOfFax; }
if(parent.PersonDoNotCall != null ){  acc.PersonDoNotCall = parent.PersonDoNotCall; }
if(parent.PersonEmailBouncedReason != null ){  acc.PersonEmailBouncedReason = parent.PersonEmailBouncedReason; }
if(parent.PersonEmailBouncedDate != null ){  acc.PersonEmailBouncedDate = parent.PersonEmailBouncedDate; }                
            }else{
                If(parent.Name != null){
                    acc.Name = parent.Name;
                }
                
            }
            If(acc.Preferred_Sales_Retailer__c != null){
                acc.Owner_Retailer__c = acc.Preferred_Sales_Retailer__c;
            }
            
            
            If(parent.AccountSource != null){
                acc.AccountSource = parent.AccountSource;
            }
            If(parent.Additional_Finance__c != null){
                acc.Additional_Finance__c = parent.Additional_Finance__c;
            }
            If(parent.Additional_Notes__pc != null){
                acc.Additional_Notes__pc = parent.Additional_Notes__pc;
            }
            If(parent.ADDRESS_2__c != null){
                acc.ADDRESS_2__c = parent.ADDRESS_2__c;
            }
            If(parent.ADDRESS_3__c != null){
                acc.ADDRESS_3__c = parent.ADDRESS_3__c;
            }
            If(parent.ADDRESS_4__c != null){
                acc.ADDRESS_4__c = parent.ADDRESS_4__c;
            }
            If(parent.Address_local__c != null){
                acc.Address_local__c = parent.Address_local__c;
            }
            If(parent.Address_Validation_Status__pc != null){
                acc.Address_Validation_Status__pc = parent.Address_Validation_Status__pc;
            }
            If(parent.Alternative_Key__c != null){
                acc.Alternative_Key__c = parent.Alternative_Key__c;
            }
            If(parent.Annual_Mileage__pc != null){
                acc.Annual_Mileage__pc = parent.Annual_Mileage__pc;
            }
            If(parent.AnnualRevenue != null){
                acc.AnnualRevenue = parent.AnnualRevenue;
            }
            If(parent.aop_Country__pc != null){
                acc.aop_Country__pc = parent.aop_Country__pc;
            }
            If(parent.B2C_Type__c != null){
                acc.B2C_Type__c = parent.B2C_Type__c;
            }         
            If(parent.BillingCountry != null){
                acc.BillingCountry = parent.BillingCountry;
            }
            If(parent.BillingGeocodeAccuracy != null){
                acc.BillingGeocodeAccuracy = parent.BillingGeocodeAccuracy;
            }
            If(parent.BillingLatitude != null){
                acc.BillingLatitude = parent.BillingLatitude;
            }
            If(parent.BillingPostalCode != null){
                acc.BillingPostalCode = parent.BillingPostalCode;
            }
            If(parent.BillingState != null){
                acc.BillingState = parent.BillingState;
            }
            If(parent.BillingStreet != null){
                acc.BillingStreet = parent.BillingStreet;
            }           
            If(parent.Body_Shop__c != null){
                acc.Body_Shop__c = parent.Body_Shop__c;
            }
            If(parent.Budget_Amount_per_Vehicle__c != null){
                acc.Budget_Amount_per_Vehicle__c = parent.Budget_Amount_per_Vehicle__c;
            }
            If(parent.Business_Appointment_Last_Visited_Date__c != null){
                acc.Business_Appointment_Last_Visited_Date__c = parent.Business_Appointment_Last_Visited_Date__c;
            }
            If(parent.Buyback__c != null){
                acc.Buyback__c = parent.Buyback__c;
            }
            If(parent.Buyback_Amount__c != null){
                acc.Buyback_Amount__c = parent.Buyback_Amount__c;
            }
            If(parent.c_udaan_marketarea2__c != null){
                acc.c_udaan_marketarea2__c = parent.c_udaan_marketarea2__c;
            }
            If(parent.Car_Allowance__c != null){
                acc.Car_Allowance__c = parent.Car_Allowance__c;
            }
            If(parent.Change_Current_Car_months__pc != null){
                acc.Change_Current_Car_months__pc = parent.Change_Current_Car_months__pc;
            }         
            If(parent.Company_Fleet_Size__c != null){
                acc.Company_Fleet_Size__c = parent.Company_Fleet_Size__c;
            }                      
            If(parent.Corporate__c != null){
                acc.Corporate__c = parent.Corporate__c;
            }        
            If(parent.Corporate_Programme_Code__c != null){
                acc.Corporate_Programme_Code__c = parent.Corporate_Programme_Code__c;
            }
            If(parent.Country_ISO_Code__pc != null){
                acc.Country_ISO_Code__pc = parent.Country_ISO_Code__pc;
            }
            If(parent.CPF__c != null){
                acc.CPF__c = parent.CPF__c;
            }                    
            If(parent.CurrencyIsoCode != null){
                acc.CurrencyIsoCode = parent.CurrencyIsoCode;
            }
            If(parent.CustomerID__c != null){
                acc.CustomerID__c = parent.CustomerID__c;
            }
            If(parent.Data_Enrichment_Priority_Effective_To__c != null){
                acc.Data_Enrichment_Priority_Effective_To__c = parent.Data_Enrichment_Priority_Effective_To__c;
            }
            If(parent.Data_Enrichment_Priority_Level__c != null){
                acc.Data_Enrichment_Priority_Level__c = parent.Data_Enrichment_Priority_Level__c;
            }       
            If(parent.Dealer_CI_Code__c != null){
                acc.Dealer_CI_Code__c = parent.Dealer_CI_Code__c;
            }         
            If(parent.Description != null){
                acc.Description = parent.Description;
            }
            If(parent.Direct_Mail_Opt_Out__pc != null){
                acc.Direct_Mail_Opt_Out__pc = parent.Direct_Mail_Opt_Out__pc;
            }          
            If(parent.Driving_Experience_Interests__pc != null){
                acc.Driving_Experience_Interests__pc = parent.Driving_Experience_Interests__pc;
            }
            If(parent.Email_used_for_Udaan__c != null){
                acc.Email_used_for_Udaan__c = parent.Email_used_for_Udaan__c;
            }
            If(parent.Email2__pc != null){
                acc.Email2__pc = parent.Email2__pc;
            }
            If(parent.Email3__pc != null){
                acc.Email3__pc = parent.Email3__pc;
            }
            If(parent.Employer_Company__c != null){
                acc.Employer_Company__c = parent.Employer_Company__c;
            }
            If(parent.End_Date__c != null){
                acc.End_Date__c = parent.End_Date__c;
            }
            If(parent.End_or_Service__c != null){
                acc.End_or_Service__c = parent.End_or_Service__c;
            }
            If(parent.Essential_Use_of_the_Car__pc != null){
                acc.Essential_Use_of_the_Car__pc = parent.Essential_Use_of_the_Car__pc;
            }
            If(parent.et4ae5__HasOptedOutOfMobile__pc != null){
                acc.et4ae5__HasOptedOutOfMobile__pc = parent.et4ae5__HasOptedOutOfMobile__pc;
            }
            If(parent.Financed__c != null){
                acc.Financed__c = parent.Financed__c;
            }
            If(parent.Fleet_Customer_Category__c != null){
                acc.Fleet_Customer_Category__c = parent.Fleet_Customer_Category__c;
            }
            If(parent.Fleet_Manager__c != null){
                acc.Fleet_Manager__c = parent.Fleet_Manager__c;
            }
            If(parent.FPACE_Marketing__pc != null){
                acc.FPACE_Marketing__pc = parent.FPACE_Marketing__pc;
            }
            If(parent.Gender__pc != null){
                acc.Gender__pc = parent.Gender__pc;
            }
            If(parent.Group_Company_Location__c != null){
                acc.Group_Company_Location__c = parent.Group_Company_Location__c;
            }
            If(parent.Group_Company_Name__c != null){
                acc.Group_Company_Name__c = parent.Group_Company_Name__c;
            }
            If(parent.Guest_Name__pc != null){
                acc.Guest_Name__pc = parent.Guest_Name__pc;
            }           
            If(parent.Household_Income__pc != null){
                acc.Household_Income__pc = parent.Household_Income__pc;
            }
            If(parent.Incorrect_Address__c != null){
                acc.Incorrect_Address__c = parent.Incorrect_Address__c;
            }
            If(parent.Incorrect_Email__c != null){
                acc.Incorrect_Email__c = parent.Incorrect_Email__c;
            }
            If(parent.Incorrect_Phone_Number__c != null){
                acc.Incorrect_Phone_Number__c = parent.Incorrect_Phone_Number__c;
            }
            If(parent.Industry != null){
                acc.Industry = parent.Industry;
            }
            If(parent.Interests__pc != null){
                acc.Interests__pc = parent.Interests__pc;
            }
            If(parent.International_Account__c != null){
                acc.International_Account__c = parent.International_Account__c;
            }
            If(parent.Invoice_Value__c != null){
                acc.Invoice_Value__c = parent.Invoice_Value__c;
            }
            If(parent.Jaguar_Gold_Starred__pc != null){
                acc.Jaguar_Gold_Starred__pc = parent.Jaguar_Gold_Starred__pc;
            }
            If(parent.Jaguar_Red_Flagged_Date__pc != null){
                acc.Jaguar_Red_Flagged_Date__pc = parent.Jaguar_Red_Flagged_Date__pc;
            }
            If(parent.JLR_Department_Name__c != null){
                acc.JLR_Department_Name__c = parent.JLR_Department_Name__c;
            }
            If(parent.JLR_Location__c != null){
                acc.JLR_Location__c = parent.JLR_Location__c;
            }
            If(parent.Land_Rover_Gold_Starred_Date__pc != null){
                acc.Land_Rover_Gold_Starred_Date__pc = parent.Land_Rover_Gold_Starred_Date__pc;
            }
            If(parent.Land_Rover_Red_Flagged_Date__pc != null){
                acc.Land_Rover_Red_Flagged_Date__pc = parent.Land_Rover_Red_Flagged_Date__pc;
            }
            If(parent.Language__pc != null){
                acc.Language__pc = parent.Language__pc;
            }
            If(parent.Last_Selling_Retailer__c != null){
                acc.Last_Selling_Retailer__c = parent.Last_Selling_Retailer__c;
            }
            If(parent.LastName != null){
                acc.LastName = parent.LastName;
            }
            If(parent.LegalEntityID__c != null){
                acc.LegalEntityID__c = parent.LegalEntityID__c;
            }
            If(parent.Likes_About_Current_Car__pc != null){
                acc.Likes_About_Current_Car__pc = parent.Likes_About_Current_Car__pc;
            }
            If(parent.Loyalty_Scheme__c != null){
                acc.Loyalty_Scheme__c = parent.Loyalty_Scheme__c;
            }
            If(parent.Loyalty_Scheme_Reference__c != null){
                acc.Loyalty_Scheme_Reference__c = parent.Loyalty_Scheme_Reference__c;
            }
            If(parent.Marital_Status__pc != null){
                acc.Marital_Status__pc = parent.Marital_Status__pc;
            }
            If(parent.Membership_Number__pc != null){
                acc.Membership_Number__pc = parent.Membership_Number__pc;
            }
            If(parent.MENA_Reference__c != null){
                acc.MENA_Reference__c = parent.MENA_Reference__c;
            }
            If(parent.MENA_Reference__pc != null){
                acc.MENA_Reference__pc = parent.MENA_Reference__pc;
            }
            If(parent.MENA_Reference2__pc != null){
                acc.MENA_Reference2__pc = parent.MENA_Reference2__pc;
            }
            If(parent.Mileage_per_Months_of_Vehicles_purchased__c != null){
                acc.Mileage_per_Months_of_Vehicles_purchased__c = parent.Mileage_per_Months_of_Vehicles_purchased__c;
            }
            If(parent.Ministry_OR_Government_Department_Name__c != null){
                acc.Ministry_OR_Government_Department_Name__c = parent.Ministry_OR_Government_Department_Name__c;
            }
            If(parent.Monthly_Amount__c != null){
                acc.Monthly_Amount__c = parent.Monthly_Amount__c;
            }
            If(parent.Must_Have_Features__pc != null){
                acc.Must_Have_Features__pc = parent.Must_Have_Features__pc;
            }
            If(parent.Next_Activity_Date__c != null){
                acc.Next_Activity_Date__c = parent.Next_Activity_Date__c;
            }
            If(parent.Next_Activity_Date__pc != null){
                acc.Next_Activity_Date__pc = parent.Next_Activity_Date__pc;
            }
            If(parent.No_of_Cars_In_Household__pc != null){
                acc.No_of_Cars_In_Household__pc = parent.No_of_Cars_In_Household__pc;
            }
            If(parent.No_of_Children__pc != null){
                acc.No_of_Children__pc = parent.No_of_Children__pc;
            }
            If(parent.No_of_Passengers__pc != null){
                acc.No_of_Passengers__pc = parent.No_of_Passengers__pc;
            }
            If(parent.No_of_People_In_Household__pc != null){
                acc.No_of_People_In_Household__pc = parent.No_of_People_In_Household__pc;
            }
            If(parent.Nominating_Retailer__c != null){
                acc.Nominating_Retailer__c = parent.Nominating_Retailer__c;
            }
            If(parent.NSC_Importer__c != null){
                acc.NSC_Importer__c = parent.NSC_Importer__c;
            }
            If(parent.ntt_Jaguar_Status__c != null){
                acc.ntt_Jaguar_Status__c = parent.ntt_Jaguar_Status__c;
            }
            If(parent.ntt_Land_Rover_Status__c != null){
                acc.ntt_Land_Rover_Status__c = parent.ntt_Land_Rover_Status__c;
            }
            If(parent.Num_of_Management_Vehicles__c != null){
                acc.Num_of_Management_Vehicles__c = parent.Num_of_Management_Vehicles__c;
            }
            If(parent.Num_of_Vehicles_Traded_In__c != null){
                acc.Num_of_Vehicles_Traded_In__c = parent.Num_of_Vehicles_Traded_In__c;
            }
            If(parent.NumberOfEmployees != null){
                acc.NumberOfEmployees = parent.NumberOfEmployees;
            }
            If(parent.Occupation__pc != null){
                acc.Occupation__pc = parent.Occupation__pc;
            }
            
            If(parent.OwnerId != null){
                //mebbe
           //     acc.OwnerId = parent.OwnerId;
            }
            If(parent.Owners_Club_Requested__pc != null){
                acc.Owners_Club_Requested__pc = parent.Owners_Club_Requested__pc;
            }
            
            If(parent.Parent_Retailer__c != null){
                //mebbe
                acc.Parent_Retailer__c = parent.Parent_Retailer__c;
            }            
            If(parent.Permissions_for_Contact__c != null){
                acc.Permissions_for_Contact__c = parent.Permissions_for_Contact__c;
            }
            If(parent.PersonAssistantName != null){
                acc.PersonAssistantName = parent.PersonAssistantName;
            }
            If(parent.PersonAssistantPhone != null){
                acc.PersonAssistantPhone = parent.PersonAssistantPhone;
            }
            If(parent.PersonDepartment != null){
                acc.PersonDepartment = parent.PersonDepartment;
            }
            If(parent.PersonDoNotCall != null){
                acc.PersonDoNotCall = parent.PersonDoNotCall;
            }
            If(parent.PersonEmail != null){
                acc.PersonEmail = parent.PersonEmail;
            }
            If(parent.PersonEmailBouncedDate != null){
                acc.PersonEmailBouncedDate = parent.PersonEmailBouncedDate;
            }
            If(parent.PersonEmailBouncedReason != null){
                acc.PersonEmailBouncedReason = parent.PersonEmailBouncedReason;
            }
            If(parent.PersonFirstNameLocal != null){
                acc.PersonFirstNameLocal = parent.PersonFirstNameLocal;
            }
            If(parent.PersonHasOptedOutOfEmail != null){
                acc.PersonHasOptedOutOfEmail = parent.PersonHasOptedOutOfEmail;
            }
            If(parent.PersonHasOptedOutOfFax != null){
                acc.PersonHasOptedOutOfFax = parent.PersonHasOptedOutOfFax;
            }
            If(parent.PersonHomePhone != null){
                acc.PersonHomePhone = parent.PersonHomePhone;
            }
            If(parent.PersonIndividualId != null){
                acc.PersonIndividualId = parent.PersonIndividualId;
            }          
            If(parent.PersonLeadSource != null){
                acc.PersonLeadSource = parent.PersonLeadSource;
            }
            If(parent.PersonMailingCity != null){
                acc.PersonMailingCity = parent.PersonMailingCity;
            }
            If(parent.PersonMailingGeocodeAccuracy != null){
                acc.PersonMailingGeocodeAccuracy = parent.PersonMailingGeocodeAccuracy;
            }
            If(parent.PersonMailingLatitude != null){
                acc.PersonMailingLatitude = parent.PersonMailingLatitude;
            }
            If(parent.PersonMailingLongitude != null){
                acc.PersonMailingLongitude = parent.PersonMailingLongitude;
            }
            If(parent.PersonMailingPostalCode != null){
                acc.PersonMailingPostalCode = parent.PersonMailingPostalCode;
            }
            If(parent.PersonMailingState != null){
                acc.PersonMailingState = parent.PersonMailingState;
            }
            If(parent.PersonOtherCity != null){
                acc.PersonOtherCity = parent.PersonOtherCity;
            }
            If(parent.PersonOtherGeocodeAccuracy != null){
                acc.PersonOtherGeocodeAccuracy = parent.PersonOtherGeocodeAccuracy;
            }
            If(parent.PersonOtherLatitude != null){
                acc.PersonOtherLatitude = parent.PersonOtherLatitude;
            }
            If(parent.PersonOtherLongitude != null){
                acc.PersonOtherLongitude = parent.PersonOtherLongitude;
            }
            If(parent.PersonOtherPhone != null){
                acc.PersonOtherPhone = parent.PersonOtherPhone;
            }
            If(parent.PersonOtherPostalCode != null){
                acc.PersonOtherPostalCode = parent.PersonOtherPostalCode;
            }
            If(parent.PersonOtherState != null){
                acc.PersonOtherState = parent.PersonOtherState;
            }
            If(parent.PersonOtherStreet != null){
                acc.PersonOtherStreet = parent.PersonOtherStreet;
            }
            If(parent.PersonTitle != null){
                acc.PersonTitle = parent.PersonTitle;
            }
            If(parent.Phone != null){
                acc.Phone = parent.Phone;
            }
            If(parent.Prefecture__c != null){
                acc.Prefecture__c = parent.Prefecture__c;
            }
            If(parent.Preferred_Contact_Time__pc != null){
                acc.Preferred_Contact_Time__pc = parent.Preferred_Contact_Time__pc;
            }
            
            If(parent.Preferred_Service_Retailer__c != null){
                acc.Preferred_Service_Retailer__c = parent.Preferred_Service_Retailer__c;
            }         
            If(parent.Pseudo_Account_Owner__c != null){
                acc.Pseudo_Account_Owner__c = parent.Pseudo_Account_Owner__c;
            }
            If(parent.Rating != null){
                acc.Rating = parent.Rating;
            }
            If(parent.Record_Sub_Type__c != null){
                acc.Record_Sub_Type__c = parent.Record_Sub_Type__c;
            }
            If(parent.Region_or_Market__c != null){
                acc.Region_or_Market__c = parent.Region_or_Market__c;
            }
            If(parent.Regional_State_Code__c != null){
                acc.Regional_State_Code__c = parent.Regional_State_Code__c;
            }
            If(parent.Retailer__c != null){
                acc.Retailer__c = parent.Retailer__c;
            }
            If(parent.Retailer__pc != null){
                acc.Retailer__pc = parent.Retailer__pc;
            }           
            If(parent.Retailer_Email__c != null){
                acc.Retailer_Email__c = parent.Retailer_Email__c;
            }         
            If(parent.Retailer_Status__c != null){
                acc.Retailer_Status__c = parent.Retailer_Status__c;
            }
            If(parent.Retailer_Type__c != null){
                acc.Retailer_Type__c = parent.Retailer_Type__c;
            }
            If(parent.Sales_Region__c != null){
                acc.Sales_Region__c = parent.Sales_Region__c;
            }
            If(parent.Salutation != null){
                acc.Salutation = parent.Salutation;
            }          
            If(parent.Service_Id__c != null){
                acc.Service_Id__c = parent.Service_Id__c;
            }
            If(parent.ShippingCity != null){
                acc.ShippingCity = parent.ShippingCity;
            }
            If(parent.ShippingCountry != null){
                acc.ShippingCountry = parent.ShippingCountry;
            }
            If(parent.ShippingGeocodeAccuracy != null){
                acc.ShippingGeocodeAccuracy = parent.ShippingGeocodeAccuracy;
            }
            If(parent.ShippingLongitude != null){
                acc.ShippingLongitude = parent.ShippingLongitude;
            }
            If(parent.ShippingPostalCode != null){
                acc.ShippingPostalCode = parent.ShippingPostalCode;
            }
            If(parent.ShippingState != null){
                acc.ShippingState = parent.ShippingState;
            }
            If(parent.Site != null){
                acc.Site = parent.Site;
            }
            If(parent.Site__c != null){
                acc.Site__c = parent.Site__c;
            }
            If(parent.Site__pc != null){
                acc.Site__pc = parent.Site__pc;
            }
            If(parent.Start_Date__c != null){
                acc.Start_Date__c = parent.Start_Date__c;
            }
            If(parent.Started_Trading__c != null){
                acc.Started_Trading__c = parent.Started_Trading__c;
            }
            If(parent.Stopped_Trading__c != null){
                acc.Stopped_Trading__c = parent.Stopped_Trading__c;
            }
            If(parent.SURNAME_2__c != null){
                acc.SURNAME_2__c = parent.SURNAME_2__c;
            }
            If(parent.Term_Mileage__c != null){
                acc.Term_Mileage__c = parent.Term_Mileage__c;
            }
            If(parent.TickerSymbol != null){
                acc.TickerSymbol = parent.TickerSymbol;
            }
            If(parent.TimeLastSentToDMS__c != null){
                acc.TimeLastSentToDMS__c = parent.TimeLastSentToDMS__c;
            }
            If(parent.Trade_In_Brand__c != null){
                acc.Trade_In_Brand__c = parent.Trade_In_Brand__c;
            }
            If(parent.Trade_in_Color__c != null){
                acc.Trade_in_Color__c = parent.Trade_in_Color__c;
            }
            If(parent.Trade_in_Mileage__c != null){
                acc.Trade_in_Mileage__c = parent.Trade_in_Mileage__c;
            }
            If(parent.Trade_in_Model__c != null){
                acc.Trade_in_Model__c = parent.Trade_in_Model__c;
            }
            If(parent.Trade_in_Model_Year__c != null){
                acc.Trade_in_Model_Year__c = parent.Trade_in_Model_Year__c;
            }
            If(parent.Trade_In_Valuation__pc != null){
                acc.Trade_In_Valuation__pc = parent.Trade_In_Valuation__pc;
            }
            If(parent.Trade_in_Value__c != null){
                acc.Trade_in_Value__c = parent.Trade_in_Value__c;
            }
            If(parent.Trading_Partner_Type__c != null){
                acc.Trading_Partner_Type__c = parent.Trading_Partner_Type__c;
            }
            If(parent.Translation_Language_Key__pc != null){
                acc.Translation_Language_Key__pc = parent.Translation_Language_Key__pc;
            }
            If(parent.Type != null){
                acc.Type = parent.Type;
            }
            If(parent.Type_of_Leasing__c != null){
                acc.Type_of_Leasing__c = parent.Type_of_Leasing__c;
            }
            If(parent.Type_of_Rental__c != null){
                acc.Type_of_Rental__c = parent.Type_of_Rental__c;
            }
            If(parent.USER_CHOOSER_OR_DRIVER__c != null){
                acc.USER_CHOOSER_OR_DRIVER__c = parent.USER_CHOOSER_OR_DRIVER__c;
            }
            If(parent.Usual_Method_of_Finance__pc != null){
                acc.Usual_Method_of_Finance__pc = parent.Usual_Method_of_Finance__pc;
            }
            If(parent.Vehicle_purchased_for__c != null){
                acc.Vehicle_purchased_for__c = parent.Vehicle_purchased_for__c;
            }
            If(parent.VITAL_Ref__c != null){
                acc.VITAL_Ref__c = parent.VITAL_Ref__c;
            }
            If(parent.Website != null){
                acc.Website = parent.Website;
            }
            If(parent.Who_Else_Will_be_Driving_the_Car__pc != null){
                acc.Who_Else_Will_be_Driving_the_Car__pc = parent.Who_Else_Will_be_Driving_the_Car__pc;
            }         
            If(parent.X17_LRE_Kochi__c != null){
                acc.X17_LRE_Kochi__c = parent.X17_LRE_Kochi__c;
            }
            If(parent.After_Sales_Region__c != null){
                acc.After_Sales_Region__c = parent.After_Sales_Region__c;
            }
            If(parent.aop_Last_Qualifying_Event__pc != null){
                acc.aop_Last_Qualifying_Event__pc = parent.aop_Last_Qualifying_Event__pc;
            }
            If(parent.Birthdate_Hidden__pc != null){
                acc.Birthdate_Hidden__pc = parent.Birthdate_Hidden__pc;
            }
            If(parent.Buyback_Percentage__c != null){
                acc.Buyback_Percentage__c = parent.Buyback_Percentage__c;
            }
            If(parent.c_udaan_marketarea1__c != null){
                acc.c_udaan_marketarea1__c = parent.c_udaan_marketarea1__c;
            }
            If(parent.Checked_for_Deletion__pc != null){
                acc.Checked_for_Deletion__pc = parent.Checked_for_Deletion__pc;
            }      
            If(parent.Deceased_Date__pc != null){
                acc.Deceased_Date__pc = parent.Deceased_Date__pc;
            }
            If(parent.Dislikes_About_Current_Car__pc != null){
                acc.Dislikes_About_Current_Car__pc = parent.Dislikes_About_Current_Car__pc;
            }
            If(parent.Embassy_Name__c != null){
                acc.Embassy_Name__c = parent.Embassy_Name__c;
            }
            If(parent.Employment_Status__pc != null){
                acc.Employment_Status__pc = parent.Employment_Status__pc;
            }
            If(parent.et4ae5__Mobile_Country_Code__pc != null){
                acc.et4ae5__Mobile_Country_Code__pc = parent.et4ae5__Mobile_Country_Code__pc;
            }
            If(parent.Fleet_purchasing_policy__c != null){
                acc.Fleet_purchasing_policy__c = parent.Fleet_purchasing_policy__c;
            }
            If(parent.Is_PII_Data_Conflict__c != null){
                acc.Is_PII_Data_Conflict__c = parent.Is_PII_Data_Conflict__c;
            }
            If(parent.Jaguar_Gold_Starred_Date__pc != null){
                acc.Jaguar_Gold_Starred_Date__pc = parent.Jaguar_Gold_Starred_Date__pc;
            }
            If(parent.Jaguar_Red_Flagged__pc != null){
                acc.Jaguar_Red_Flagged__pc = parent.Jaguar_Red_Flagged__pc;
            }
            If(parent.Land_Rover_Gold_Starred__pc != null){
                acc.Land_Rover_Gold_Starred__pc = parent.Land_Rover_Gold_Starred__pc;
            }
            If(parent.Land_Rover_Red_Flagged__pc != null){
                acc.Land_Rover_Red_Flagged__pc = parent.Land_Rover_Red_Flagged__pc;
            }
            If(parent.Net_Worth__pc != null){
                acc.Net_Worth__pc = parent.Net_Worth__pc;
            }
            If(parent.Number_of_Open_Cases__c != null){
                acc.Number_of_Open_Cases__c = parent.Number_of_Open_Cases__c;
            }
            If(parent.Number_of_Open_Cases__pc != null){
                acc.Number_of_Open_Cases__pc = parent.Number_of_Open_Cases__pc;
            }
            If(parent.Other_Phone_Hidden__pc != null){
                acc.Other_Phone_Hidden__pc = parent.Other_Phone_Hidden__pc;
            }          
            If(parent.SAP_ID__c != null){
                acc.SAP_ID__c = parent.SAP_ID__c;
            }
            If(parent.Space_and_Towing__pc != null){
                acc.Space_and_Towing__pc = parent.Space_and_Towing__pc;
            }
            If(parent.Supplier_Vendor_Name__c != null){
                acc.Supplier_Vendor_Name__c = parent.Supplier_Vendor_Name__c;
            }
            If(parent.TimeLastSentToDMS__pc != null){
                acc.TimeLastSentToDMS__pc = parent.TimeLastSentToDMS__pc;
            }
            If(parent.Trade_in_Grade__c != null){
                acc.Trade_in_Grade__c = parent.Trade_in_Grade__c;
            }
            If(parent.Vehicle_Trade_In__c != null){
                acc.Vehicle_Trade_In__c = parent.Vehicle_Trade_In__c;
            }
            If(parent.Vehicles_sourced_through_tender__c != null){
                acc.Vehicles_sourced_through_tender__c = parent.Vehicles_sourced_through_tender__c;
            }
            If(parent.Who_is_the_Main_Driver__pc != null){
                acc.Who_is_the_Main_Driver__pc = parent.Who_is_the_Main_Driver__pc;
            }
            
            
        }
        
        
        
    }
}