@isTest
public class TestUtility {
    
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    public static Id contactRecordtype = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Retailer Contact').getRecordTypeId();
    public static Id salesProcessOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Process with RDA').getRecordTypeId();
    public static Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Finance').getRecordTypeId();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id assetRecordType = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
    
    public static User createPortaluser(String Country,String profileName){
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = :profileName limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test@test.test';
        commUser.ProfileId = salesExecutiveProfile.Id;
        commUser.UserName = 'test@test.'+Math.random()*100+'retailer';
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.Country = Country;
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        if(Country == 'India')
            commUser.DefaultCurrencyIsoCode ='INR';        
        else
            commUser.DefaultCurrencyIsoCode ='GBP';   
        commUser.Market__c = 'IN';
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert commUser;
        }
        return commUser;
    }
    
    public static User createPortalsubOrdinateuser(String aliasName, String Country,String profileName, Id portalManagerUserId){
        Account retailerAccount = [select Id from Account Where RecordTypeId =:AccountUtilities.RecordTypes.get('Retailer').Id];
        Profile salesExecutiveProfile = [select Id from Profile where Name = :profileName limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test@test.test';
        commUser.ProfileId = salesExecutiveProfile.Id;
        commUser.UserName = 'test@test.test.retailer'+aliasName;
        commUser.Alias =aliasName;
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.Country = Country;
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        commUser.DefaultCurrencyIsoCode ='GBP';
        commUser.Market__c = 'JP';
        commUser.Partner_Manager__c = portalManagerUserId;
        commUser.ManagerId = portalManagerUserId;
        // Test.startTest();
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert commUser;
        }
        /* PermissionSet p= [SELECT Id FROM PermissionSet WHERE Name='Stock_Controller_RDA'];
PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = p.Id, AssigneeId = commUser.Id);
insert psa; 
Test.stopTest();*/
        return commUser;
    }
    
    public static User CreateMarketSpecificUser(String aliasName,String profileName,String Country,String CountryCode,String CurrencyCode,String RegionMarket){
        Profile Profile = [select Id from Profile where Name = :profileName limit 1];
        
        User INMktUser = new User();
        INMktUser.Phone = '07681102495';
        INMktUser.Email = 'test@test.test';
        INMktUser.ProfileId = Profile.Id;
        INMktUser.UserName = 'test@test.test.admin'+aliasName;
        INMktUser.Alias =aliasName;
        INMktUser.FirstName = 'Test';
        INMktUser.LastName = 'Test';
        INMktUser.LanguageLocaleKey = 'en_GB';
        INMktUser.LocaleSidKey = 'en_GB';
        INMktUser.TimeZoneSidKey = 'Asia/Kolkata';
        INMktUser.EmailEncodingKey = 'UTF-8';
        INMktUser.Country = Country;
        INMktUser.Country_ISO_Code__c = CountryCode;
        INMktUser.DefaultCurrencyIsoCode =CurrencyCode;
        INMktUser.Market__c = RegionMarket;
        
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert INMktUser;
        }
        return INMktUser;
    }
    
    
    public static Account createCorporateAccount(){
        Account account = new Account();        
        account.RecordTypeId = corporateRecordType;
        account.Name = 'Valid Firstname';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';        
        account.Retailer_Email__c = 'test@test.com';      
        account.Country_ISO_Code__c = 'IN';  
        account.Is_Primary__c = false;
        account.Phone = '1234567890';
        return account;
    }
    
    public static Account createIndividualAccount(){
        Account account = new Account();
        account.RecordTypeId = individualRecordType;
        account.LastName = 'test';
        account.FirstName = 'Valid Firstname';
        account.PersonMailingStreet = 'Valid Street';
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'IN';  
        account.Is_Primary__c = false;
        account.Phone = '1234567890';
        return account;
    }
    
    public static Account createAURetailerAccount(){
        Account account = new Account();        
        account.RecordTypeId = RetailerRecordType;
        account.Name = 'Valid Firstname';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';        
        account.Retailer_Email__c = 'test@test.com';      
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = false;
        account.Phone = '1234567890';
        return account;
    }
    
    public static List<Contact> createContact(id accountId,integer countValue){
        List<Contact> contactList = new List<Contact>();
        for(integer i=0;i<countValue;i++){
            Contact cont = new Contact();
            cont.accountId = accountId;
            cont.FirstName = 'Test F Name';
            cont.email = 'test@testdatacontact.dev';
            cont.lastName = 'Test F Name';
            contactList.add(cont);
        }
        insert contactList;
        return contactList;
    }
    
    public static Opportunity createOpportunity(id accountId,String StageName){
        Opportunity opp = new Opportunity();
        opp.accountid = accountId;
        opp.Name = 'Test Sales Process Opp';
        opp.StageName = StageName;
        opp.closeDate = system.today()+30;
        return opp;
    }
    
    public static contract createContract(id accountId,id OpportunityId,String Status){
        contract cont = new contract();
        cont.RecordTypeId = contractRecordType;
        cont.accountId = accountId;
        cont.Opportunity__c = OpportunityId;
        cont.Status = 'Draft';
        cont.Contract_Status__c = Status;
        cont.StartDate = system.today()+1;
        cont.endDate = system.today()+30;
        return cont;
    }
    public static Product2 createProduct(){
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        return p2;
    }
    public static Vehicle_specification__c createVehicleSpecification(){
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        return makeVehicle;            
    }
    
    public static Asset createAsset(id accountId,id product2Id){
        Vehicle_specification__c vehicleSpecify = createVehicleSpecification();
        
        Asset testasset = new Asset();
        testasset.Name = 'ABCDEFGH1234';
        testasset.AccountId = accountId;
        testasset.Brand__c = vehicleSpecify.Id;
        testasset.product2Id =product2Id;
        testasset.Vin__c = 'ABCDEFGH1234';
        testasset.Derivative__c  =product2Id;
        testasset.Status = Label.Asset_Status_List.split(',')[0];
        testasset.Vista_Status__c='Customer Handover';
        testasset.RecordTypeId =  assetRecordType;
        insert testasset;
        return testasset;
    }
    
    public static OpportunityLineItem createLineItem(id oppId,id prodId,id assetId){
        Id standardBookId = test.getStandardPricebookId();
        PriceBookEntry pBE = new PriceBookEntry(IsActive = true, UseStandardPrice = false, Product2Id = prodId, PriceBook2Id = standardBookId, UnitPrice = 1.0);
        insert pBE;
        OpportunityLineItem newItem = new OpportunityLineItem(asset__c = assetId,OpportunityId =oppId, PriceBookEntryId = pBE.Id, Quantity = 1, TotalPrice = 1);
        insert newItem;
        return newItem;
    }
}