@isTest
public class Account_Secondary_Account_Creator_TEST {
    
    @isTest
    public static void test_create_Person_Account(){
        Account ret = TestClass_AccountCreator.CreateRetailer();
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        acc.LastName = 'Bobby';
        acc.FirstName = 'Ricky';
        acc.PersonEmail = 'Shake@Bake.usa';
        acc.AccountSource ='te';  
        acc.Additional_Notes__pc ='te';
        acc.ADDRESS_2__c ='te';
        acc.ADDRESS_3__c ='te';
        acc.ADDRESS_4__c ='te';
        acc.Address_local__c ='te';  
        acc.Alternative_Key__c ='te'; 
        acc.BillingCountry ='te';        
        acc.BillingPostalCode ='te';
        acc.BillingState ='te';
        acc.BillingStreet ='te';     
       //a acc.Corporate_Code__c ='te';
        acc.Corporate_Programme_Code__c ='te';
        acc.Country_ISO_Code__pc ='te';
        acc.CPF__c ='te';     
        acc.Dealer_CI_Code__c ='te';    
        acc.Description ='te';     
        acc.DMS_Identifier__pc ='te';
        acc.Driving_Experience_Interests__pc ='te';
        acc.Email_used_for_Udaan__c ='te@te.com';
        acc.Email2__pc ='te@te.com';
        acc.Email3__pc ='te@te.com';
        acc.Employer_Company__c ='tt';    
        acc.Gender__pc ='Male';
        acc.Group_Company_Location__c ='te';
        acc.Group_Company_Name__c ='te';
        acc.Guest_Name__pc ='te'; 
        
        acc.Interests__pc ='te';
        acc.JLR_Department_Name__c ='te';
        acc.JLR_Location__c ='te';     
        
        acc.LegalEntityID__c ='te';
        acc.Likes_About_Current_Car__pc ='te';    
        acc.Marital_Status__pc ='Single';
        acc.Membership_Number__pc ='te';
       //a acc.MENA_Reference__c ='te';
       acc.MENA_Reference__pc ='te';
        acc.MENA_Reference2__pc ='te';     
        acc.Must_Have_Features__pc ='te';        
        acc.No_of_Passengers__pc ='te';         
        
        acc.Permissions_for_Contact__c ='te';
        acc.PersonAssistantName ='te';
        acc.PersonAssistantPhone ='234324234';
        acc.PersonDepartment ='te';     
        acc.PersonEmailBouncedReason ='te';
        acc.PersonFirstNameLocal ='te'; 
        acc.PersonHomePhone ='23423423443';
        acc.PersonLeadSource ='te';
        acc.PersonMailingCity ='te';            
        acc.PersonMailingPostalCode ='te';
        acc.PersonMailingState ='te';
        acc.PersonOtherCity ='te';      
        acc.PersonOtherPhone ='3244334';
        acc.PersonOtherPostalCode ='te';
        acc.PersonOtherState ='te';
        acc.PersonOtherStreet ='te';
        acc.PersonTitle ='Mr';
        acc.Phone ='12345'; 
        acc.Preferred_Contact_Time__pc ='AM';
       //a acc.Primary_Dealer_Code__c ='te';
        acc.Rating ='Hot';      
        acc.Retailer_Email__c ='test@email.com'; 
        
        acc.Salutation ='Mr';
      //a  acc.Secondary_Dealer_Code__c ='te';
        acc.Service_Id__c ='te';       
        acc.ShippingCity ='te';
        acc.ShippingCountry ='te';           
        acc.ShippingPostalCode ='te';
        acc.ShippingState ='te';
        acc.Site ='te';
        acc.Site__c ='te';
        acc.Site__pc ='te';
        acc.SURNAME_2__c ='te';
        acc.TickerSymbol ='te';       
        acc.Trade_In_Brand__c ='te';
        acc.Trade_in_Color__c ='te';
        acc.Trade_in_Model__c ='te';
        acc.Trade_in_Model_Year__c ='te';
        acc.Trade_In_Valuation__pc ='te'; 
        acc.Website ='te';
        acc.Who_Else_Will_be_Driving_the_Car__pc ='te';
             
        
        acc.Dislikes_About_Current_Car__pc ='te';
        acc.Embassy_Name__c ='te'; 
        acc.Space_and_Towing__pc ='te';
        acc.Supplier_Vendor_Name__c ='te';
        acc.Who_is_the_Main_Driver__pc ='te';
        
        insert acc;
        
        Test.startTest();
        Account acccild = new Account();
        acccild.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        acccild.LastName = 'Bibby';
        acccild.FirstName = 'Rocky';
        acccild.PersonEmail = 'Shake@Bake.usa';
        acccild.Create_Secondary_Account__c = true;
        acccild.Primary_Account__c = acc.id;
        acccild.Preferred_Sales_Retailer__c = ret.Id;
        insert acccild;
        Test.stopTest();
        Account accResilt = [Select firstname,recordtype.name from account where id =: acccild.Id];
        system.debug('accResilt '+accResilt);
        system.assert(accResilt.FirstName == 'Ricky');
        
    }
    @isTest
    public static void test_create_Corporate(){
        Account ret = TestClass_AccountCreator.CreateRetailer();
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        acc.Name = 'Bobby';
        acc.Phone = '123456789';
        insert acc;
        
        Test.startTest();
        
        Account acccild = new Account();
        acccild.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        acccild.Name = 'Bibby';  
        acccild.Phone = '123456789';
        acccild.Create_Secondary_Account__c = true;
        acccild.Primary_Account__c = acc.id;
        acccild.Preferred_Sales_Retailer__c = ret.Id;
        insert acccild;
        test.stopTest();
        Account accResilt = [Select name,recordtype.name from account where id =: acccild.Id];
        system.debug('accResilt '+accResilt);
        system.assert(accResilt.name == 'Bobby');
        
    }
    
    
}