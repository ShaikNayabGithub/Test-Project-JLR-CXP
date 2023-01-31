@isTest
public class CancelServicePlanController_Test {
public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
    
    static testmethod void test1()
    {
        
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        
        User portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'Singapore';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'APIO';
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert portalUser;
        }
        
        Id priceBookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Singapore', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c, Country_ISO_Code__c='SG' );
        insert standardPB;
            
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
            
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;

        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];

            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'SG';  
            account.Is_Primary__c = false;          
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Vin__c = 'TestAsset';
            testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            Test.startTest();
            insert testasset;
            
            Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
            spc.Vehicle_Id__c = testasset.Id; 
            spc.Start_Date__c = system.today()-10;
            spc.End_Date__c = system.today()+30;  
            spc.Contract_Term_Months__c = 30;
            
            spc.Assignment_Type__c = 'Retail';  
            spc.Country_ISO_Code__c='SG';
            spc.Market__c='APIO';

            Insert spc;
        	
        try{
            CancelServicePlanController.getAllServicePlan(testasset.Id);
            CancelServicePlanController.cancelSelectedSpc(spc.Id,null);
        Test.stopTest();
        }catch(exception e){
            
        }
    }
}
}