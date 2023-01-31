/**
 * IMPORTANT due to multiple SOQL and DML operations required within this batch, only small batches should be used
 * 
 * 
 * 
 * 
 * */


global class Batch_Transitional_Records implements Database.Batchable<sObject>, database.Stateful {

     public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    
    String query;
    
    List<Boolean> tfSettings;
    TriggerFramework__c tf = TriggerFramework__c.getInstance(UserInfo.getProfileId());
    
    global Batch_Transitional_Records(string limitInput)
    {   
    
            
        query = 'SELECT Id,   Name, CurrencyIsoCode,Current_Asset_Account__r.name, Manufacturer__c, Country_Code__c, Event_Type__c, Dealer_Code__c, Customer_Unique_ID__c, Company_Name__c, Title__c, First_Name__c, Surname_Field_1__c, Salutation__c, Address_1__c, Address_5_City__c, Address_2__c, Address_7_Postcode_Zipcode__c, Address_8_Country__c,';
        query += '     Home_Telephone_Number__c, Business_Telephone_Number__c, Mobile_Telephone_Number__c, VIN_Lookup__c, VIN__c, Email_Address_1__c, Preferred_Language__c, ';
         query += '   Complete_Suppression__c, Gender__c, Preferred_Method_of_Contact__c, Permissions_for_Contact__c, Customer_Status__c, Stripped_Individual_Name__c, Stripped_Company_Name__c, Status__c, Current_Asset_Account__c, Current_Asset_Account__r.RecordtypeId, Current_Asset_Account_Email__c, New_Created_Account__c, Matched_Existing_Account__c,';
         query += '   Reviewed__c, Dummy_email__c,  Current_Asset_Account__r.FirstName, Current_Asset_Account__r.LastName, Current_Asset_Account__r.PersonEmail, Current_Asset_Account__r.Email2__pc, Current_Asset_Account__r.Email3__pc FROM Transitional_Record__c';
            query += ' WHERE Status__c = \'New\' Limit '+limitInput; 
        
    }
       global Batch_Transitional_Records(string limitInput, string name)
    {   
    
            
            query = 'SELECT Id,   Name, CurrencyIsoCode,Current_Asset_Account__r.name, Manufacturer__c, Country_Code__c, Event_Type__c, Dealer_Code__c, Customer_Unique_ID__c, Company_Name__c, Title__c, First_Name__c, Surname_Field_1__c, Salutation__c, Address_1__c, Address_5_City__c, Address_2__c, Address_7_Postcode_Zipcode__c, Address_8_Country__c,';
        query += '     Home_Telephone_Number__c, Business_Telephone_Number__c, Mobile_Telephone_Number__c, VIN_Lookup__c, VIN__c, Email_Address_1__c, Preferred_Language__c, ';
         query += '   Complete_Suppression__c, Gender__c, Preferred_Method_of_Contact__c, Permissions_for_Contact__c, Customer_Status__c, Stripped_Individual_Name__c, Stripped_Company_Name__c, Status__c, Current_Asset_Account__c, Current_Asset_Account__r.RecordtypeId, Current_Asset_Account_Email__c, New_Created_Account__c, Matched_Existing_Account__c,';
         query += '   Reviewed__c, Dummy_email__c, Current_Asset_Account__r.FirstName, Current_Asset_Account__r.LastName, Current_Asset_Account__r.PersonEmail, Current_Asset_Account__r.Email2__pc, Current_Asset_Account__r.Email3__pc FROM Transitional_Record__c';
            query += ' WHERE Status__c = \'New\' AND Name = \'' + name+ '\'  Limit '+limitInput; 
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
  //failsafe in case someone passed in garbage to the contructor
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Transitional_Record__c> Records)
    {    
        Transitional_Record_Batch_Matching_Logic TRBML = new Transitional_Record_Batch_Matching_Logic();
        List<Transitional_Record__c> dummyEmailsTrans = new List<Transitional_Record__c>();
        List<Transitional_Record__c> primeForProcessingCustomer = new List<Transitional_Record__c>();
            List<Transitional_Record__c> tranForUpdating = new List<Transitional_Record__c>();
            List<Transitional_Record__c> primeForProcessingRetailerAccounts = new List<Transitional_Record__c>();
        For(Transitional_Record__c tran : Records){
            if(tran.Current_Asset_Account__r.RecordtypeId != retailerRecordType){
                primeForProcessingCustomer.add(tran);
            }else{
              //  if(tran.Dummy_email__c){
              //      dummyEmailsTrans.add(tran);
               // }else{
                    primeForProcessingRetailerAccounts.add(tran);
             //   }
                
            }
        }
        if(primeForProcessingCustomer != null && primeForProcessingCustomer.size() > 0){
         primeForProcessingCustomer =   TRBML.processValidEmailCustomerTrans(primeForProcessingCustomer);
                 for(Transitional_Record__c tran : primeForProcessingCustomer){
                   
                   tranForUpdating.add(tran);
                   
               }
        }
           if(primeForProcessingRetailerAccounts != null && primeForProcessingRetailerAccounts.size() > 0){
         primeForProcessingRetailerAccounts =   TRBML.processRetailerTrans(primeForProcessingRetailerAccounts);
               for(Transitional_Record__c tran : primeForProcessingRetailerAccounts){
                   
                   tranForUpdating.add(tran);
                   
               }
        }
        update tranForUpdating;
        

    }
    
    global void finish(Database.BatchableContext BC)
    {
       
    }
 
 
    
}