@isTest(seeAllData=false)
public class Batch_CVoiceServiceDataExport_Test {

    
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
    
    
    public static testmethod void TestcVoiceServiceDataExport()
    {
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        Account accountForUpsert;
        
        User runningUser = new User();
        system.runAs(new user(id=userinfo.getUserId()))
        {
            runningUser.Phone = '07681102495';
            runningUser.Email = 'test@test1.test';
            runningUser.ProfileId = systemAdmin.Id;
            runningUser.UserName = 'test@test.test.admin';
            runningUser.Alias = 'TTT';
            runningUser.UserRoleId=[select id from UserRole where Name='System Administrator' Limit 1 ].Id;
            runningUser.FirstName = 'Test';
            runningUser.LastName = 'Test';
            runningUser.Country = 'Singapore';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            runningUser.DefaultCurrencyIsoCode ='SGD';   
            runningUser.Market__c = 'APIO';
            runningUser.Country_ISO_Code__c='SG';
            Insert runningUser;
        }
        User portalUser;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'test retailer';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            insert retailerAccount;
            
            testCommContact.LastName = 'Test Name';
            testCommContact.AccountID = retailerAccount.Id;
            //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
            testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
            testCommContact.Email = 'test@test.test';
            insert testCommContact;
        }
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        portalUser = new User();
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
        portalUser.Market__c = 'MENA';
        portalUser.Country_ISO_Code__c='AE';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser;
        }
        //Product2 p2;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        //Product2 servicePlan; 
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            
            accountForUpsert= new Account();
            accountForUpsert.RecordTypeId=individualRecordType;
            accountForUpsert.LastName='Tester';
            accountForUpsert.FirstName='Test';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew1';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Insert accountForUpsert;
            
            Asset testasset = new Asset();
            testasset.Name = 'ABCDEFGH1234';
            testasset.AccountId = accountForUpsert.Id;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Vin__c = 'ABCDEFGH1234';
            testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            testasset.Vista_Status__c='Customer Handover';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            
            Service_Data__c serviceData = new Service_Data__c();
            serviceData.Service_Date__c = system.today();
        	serviceData.Asset__c = testasset.ID;
            serviceData.DMS_Repair_Order_ID__c = '123xatv';
            serviceData.Brand__c='Jaguar';
            serviceData.Business_Phone__c='1234567890';
            serviceData.City__c='Abudabi';
            serviceData.Collection_Date__c=system.today();
            serviceData.Company_Name__c='Test';
            serviceData.CorporateAccIndicator__c= false;
            serviceData.Country__c='Lebanon';
            serviceData.Country_ISO_Code__c='IN';
            serviceData.CurrencyIsoCode='USD';
            serviceData.Database_Reference_ID__c='test';
            serviceData.Dealer_Code_JLR__c='JLR68732';
            serviceData.Dms_Id__c='test';
            serviceData.Email__c='test@gmail.com';
            serviceData.First_Name__c='Test';
            serviceData.Last_Name__c='Tester';
            serviceData.Home_Phone__c='1234567890';
            serviceData.Job_Booked_Date__c=system.today();
            serviceData.Mileage_Date__c=system.today();
            serviceData.Mobile_Number__c='1234567890';
            serviceData.Model__c='Range Rover Velar';
            serviceData.Post_Code__c='12345';
            serviceData.Price_Parts__c=300;
            serviceData.Service_Repair_Date__c=system.today();
            serviceData.SR_Type__c='Warranty';
            serviceData.State__c='SK';
            Insert serviceData;
        }   
        Test.startTest();
        database.executeBatch(new Batch_CVoiceServiceDataExport());
        Test.stopTest();
    }
}