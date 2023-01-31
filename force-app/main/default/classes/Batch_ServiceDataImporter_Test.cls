@isTest(seeAllData=false)
public class Batch_ServiceDataImporter_Test {
    
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id RetailerConRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Retailer Contact').getRecordTypeId();
    public static Id corporateAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
    
    
    @TestSetup static void createCommonData() {
        aop_NationalityToISOCode__c countryIsoCode= new aop_NationalityToISOCode__c();
        countryIsoCode.Dialing_Code__c='971';
        countryIsoCode.Name='Abu Dhabi';
        countryIsoCode.aop_ISO_Code__c='AE';
        countryIsoCode.aop_Checkfront_Instance__c='Test.jhshd.com';
        Insert countryIsoCode;

        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();

        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c = 'Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE'));
        insert dupList;
    }
    
    public static testmethod void TestAssetIndividualAccountMatch()
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
            retailerAccount.Name = 'Test Account';
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        Test.startTest();
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    public static testmethod void TestAssetCorpAccountMatch()
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
            retailerAccount.Name = 'Test Account';
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
            accountForUpsert.RecordTypeId=corporateAccRecId;
            accountForUpsert.Name='Test Comp';
            accountForUpsert.Retailer_Email__c='test1@gmail.com';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew1';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Insert accountForUpsert;
            
            Contact contactForUpsert= new Contact();
            contactForUpsert.LastName='Tester';
            contactForUpsert.FirstName='Test';
            contactForUpsert.Email='test1@gmail.com';
            contactForUpsert.Email2__c='testnew@gmail.com';
            contactForUpsert.DMS_Identifier__c='87483ER';
            contactForUpsert.Title='MR';
            contactForUpsert.MobilePhone='7984938';
            contactForUpsert.HomePhone='97493843';
            contactForUpsert.AccountId=accountForUpsert.Id;
            contactForUpsert.OtherPhone='9749383';
            contactForUpsert.Country_ISO_Code__c='AE';
            contactForUpsert.aop_Country__c='Dubai';
            contactForUpsert.MailingCountry='Dubai';
            contactForUpsert.MailingCity='Test';
            contactForUpsert.MailingState='Test';
            contactForUpsert.MailingPostalCode='949384';
            contactForUpsert.RecordTypeId= RetailerConRecId;
            Insert contactForUpsert;
            
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
            Test.startTest();
            insert testasset;
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test Comp';
            SDI1.CorporateAccIndicator__c= true;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    
    public static testmethod void TestAssetCorpAccountMatch_InvalidContact()
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
            retailerAccount.Name = 'Test Account';
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
            accountForUpsert.RecordTypeId=corporateAccRecId;
            accountForUpsert.Name='Test Comp';
            accountForUpsert.Retailer_Email__c='test1@gmail.com';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew1';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Insert accountForUpsert;
            
            Contact contactForUpsert= new Contact();
            contactForUpsert.LastName='i am different';
            contactForUpsert.FirstName='new';
            contactForUpsert.Email='test1@gmail.com';
            contactForUpsert.Email2__c='testnew@gmail.com';
            contactForUpsert.DMS_Identifier__c='874836R';
            contactForUpsert.Title='MR';
            contactForUpsert.MobilePhone='7984938';
            contactForUpsert.HomePhone='97493843';
            contactForUpsert.AccountId=accountForUpsert.Id;
            contactForUpsert.OtherPhone='9749383';
            contactForUpsert.Country_ISO_Code__c='AE';
            contactForUpsert.aop_Country__c='Dubai';
            contactForUpsert.MailingCountry='Dubai';
            contactForUpsert.MailingCity='Test';
            contactForUpsert.MailingState='Test';
            contactForUpsert.MailingPostalCode='949384';
            contactForUpsert.RecordTypeId= RetailerConRecId;
            Insert contactForUpsert;
            
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
            Test.startTest();
            insert testasset;
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test Comp';
            SDI1.CorporateAccIndicator__c= true;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    public static testmethod void TestAssetCorpAccountMatch_WithoutCon()
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
            retailerAccount.Name = 'Test Account';
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
            accountForUpsert.RecordTypeId=corporateAccRecId;
            accountForUpsert.Name='Test Comp';
            accountForUpsert.Retailer_Email__c='test1@gmail.com';
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
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test Comp';
            SDI1.CorporateAccIndicator__c= true;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        Test.startTest();
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    //@isTest
    public static void TestJLRDelearIndividualAccountMatch()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=individualRecordType;
            indCustumer.LastName='Tester';
            indCustumer.FirstName='Test'; 
            indCustumer.personEmail='test1@gmail.com';
            indCustumer.PersonMobilePhone='94943092';
            indCustumer.PersonHomePhone='874394938';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='AE';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            indCustumer.Preferred_Sales_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
        	Test.startTest();
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    public static testmethod void TestJLRDelearCorpAccountMatch()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=corporateAccRecId;
            indCustumer.Name='Test Comp';
            indCustumer.Retailer_Email__c='test1@gmail.com';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='AE';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            indCustumer.Preferred_Sales_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
            Contact contactForUpsert= new Contact();
            contactForUpsert.LastName='Tester';
            contactForUpsert.FirstName='Test';
            contactForUpsert.Email='test1@gmail.com';
            contactForUpsert.Email2__c='testnew@gmail.com';
            contactForUpsert.DMS_Identifier__c='87483ER';
            contactForUpsert.Title='MR';
            contactForUpsert.MobilePhone='7984938';
            contactForUpsert.HomePhone='97493843';
            contactForUpsert.AccountId=indCustumer.Id;
            contactForUpsert.OtherPhone='9749383';
            contactForUpsert.Country_ISO_Code__c='AE';
            contactForUpsert.aop_Country__c='Dubai';
            contactForUpsert.MailingCountry='Dubai';
            contactForUpsert.MailingCity='Test';
            contactForUpsert.MailingState='Test';
            contactForUpsert.MailingPostalCode='949384';
            contactForUpsert.RecordTypeId= RetailerConRecId;
            Insert contactForUpsert;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Test.startTest();
            Insert accountForUpsert;
            
            AssetHandler.IgnoreMMIT=true;
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test Comp';
            SDI1.CorporateAccIndicator__c= true;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    
    public static testmethod void TestJLRDelearCorpAccountMatch_InvalidCon()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=corporateAccRecId;
            indCustumer.Name='Test Comp';
            indCustumer.Retailer_Email__c='test1@gmail.com';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='AE';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            indCustumer.Preferred_Sales_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
            Contact contactForUpsert= new Contact();
            contactForUpsert.LastName='Tester IN';
            contactForUpsert.FirstName='Test';
            contactForUpsert.Email='test1@gmail.com';
            contactForUpsert.Email2__c='testnew@gmail.com';
            contactForUpsert.DMS_Identifier__c='87483ER';
            contactForUpsert.Title='MR';
            contactForUpsert.MobilePhone='7984938';
            contactForUpsert.HomePhone='97493843';
            contactForUpsert.AccountId=indCustumer.Id;
            contactForUpsert.OtherPhone='9749383';
            contactForUpsert.Country_ISO_Code__c='AE';
            contactForUpsert.aop_Country__c='Dubai';
            contactForUpsert.MailingCountry='Dubai';
            contactForUpsert.MailingCity='Test';
            contactForUpsert.MailingState='Test';
            contactForUpsert.MailingPostalCode='949384';
            contactForUpsert.RecordTypeId= RetailerConRecId;
            Insert contactForUpsert;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Test.startTest();
            Insert accountForUpsert;
            
            AssetHandler.IgnoreMMIT=true;
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test Comp';
            SDI1.CorporateAccIndicator__c= true;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    public static testmethod void TestJLRDelearCorpAccountMatch_WithoutCon()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=corporateAccRecId;
            indCustumer.Name='Test Comp';
            indCustumer.Retailer_Email__c='test1@gmail.com';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='AE';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            indCustumer.Preferred_Sales_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test Comp';
            SDI1.CorporateAccIndicator__c= true;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        Test.startTest();
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    } 
    
    //@isTest
    public static void TestJLROutsideRegion_Individual()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=individualRecordType;
            indCustumer.LastName='Tester';
            indCustumer.FirstName='Test';
            indCustumer.personEmail='test12@gmail.com';
            indCustumer.PersonMobilePhone='94943092';
            indCustumer.PersonHomePhone='874394938';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='EG';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Test.startTest();
            Insert accountForUpsert;
            
            AssetHandler.IgnoreMMIT=true;
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        try{
            database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        }catch(exception e){
            
        }
        Test.stopTest();
    } 
    
    public static testmethod void TestJLROutsideRegion_CorporateWithInvalidContacts()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=corporateAccRecId;
            indCustumer.Name='Test';
            indCustumer.Retailer_Email__c='test1@gmail.com';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='EG';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
            Contact contactForUpsert= new Contact();
            contactForUpsert.LastName='Tester IN';
            contactForUpsert.FirstName='Test';
            contactForUpsert.Email='test1@gmail.com';
            contactForUpsert.Email2__c='testnew@gmail.com';
            contactForUpsert.DMS_Identifier__c='87483ER';
            contactForUpsert.Title='MR';
            contactForUpsert.MobilePhone='7984938';
            contactForUpsert.HomePhone='97493843';
            contactForUpsert.AccountId=indCustumer.Id;
            contactForUpsert.OtherPhone='9749383';
            contactForUpsert.Country_ISO_Code__c='AE';
            contactForUpsert.aop_Country__c='Dubai';
            contactForUpsert.MailingCountry='Dubai';
            contactForUpsert.MailingCity='Test';
            contactForUpsert.MailingState='Test';
            contactForUpsert.MailingPostalCode='949384';
            contactForUpsert.RecordTypeId= RetailerConRecId;
            Insert contactForUpsert;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Test.startTest();
            Insert accountForUpsert;
            
            AssetHandler.IgnoreMMIT=true;
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        try{
            database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        }catch(exception e){
            
        }
        Test.stopTest();
    }
    
    
    public static testmethod void TestJLROutsideRegion_CorporateWithContacts()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=corporateAccRecId;
            indCustumer.Name='Test';
            indCustumer.Retailer_Email__c='test1@gmail.com';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='EG';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
            Contact contactForUpsert= new Contact();
            contactForUpsert.LastName='Tester';
            contactForUpsert.FirstName='Test';
            contactForUpsert.Email='test1@gmail.com';
            contactForUpsert.Email2__c='testnew@gmail.com';
            contactForUpsert.DMS_Identifier__c='87483ER';
            contactForUpsert.Title='MR';
            contactForUpsert.MobilePhone='7984938';
            contactForUpsert.HomePhone='97493843';
            contactForUpsert.AccountId=indCustumer.Id;
            contactForUpsert.OtherPhone='9749383';
            contactForUpsert.Country_ISO_Code__c='AE';
            contactForUpsert.aop_Country__c='Dubai';
            contactForUpsert.MailingCountry='Dubai';
            contactForUpsert.MailingCity='Test';
            contactForUpsert.MailingState='Test';
            contactForUpsert.MailingPostalCode='949384';
            contactForUpsert.RecordTypeId= RetailerConRecId;
            Insert contactForUpsert;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Test.startTest();
            Insert accountForUpsert;
            
            AssetHandler.IgnoreMMIT=true;
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        try{
            database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        }catch(exception e){
            
        }
        Test.stopTest();
    }
    
    public static testmethod void TestJLROutsideRegion_CorporateWithoutContact()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=corporateAccRecId;
            indCustumer.Name='Test';
            indCustumer.Retailer_Email__c='test1@gmail.com';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='EG';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Insert accountForUpsert;
            
            AssetHandler.IgnoreMMIT=true;
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Last_Name__c='Tester';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        Test.startTest();
        try{
            database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        }catch(exception e){
            
        }
        Test.stopTest();
    }
    
    public static testmethod void TestAssetCorpAccountMatch_InvalidContactData()
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
            retailerAccount.Name = 'Test Account';
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
            accountForUpsert.RecordTypeId=corporateAccRecId;
            accountForUpsert.Name='Test Comp';
            accountForUpsert.Retailer_Email__c='test1@gmail.com';
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
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test Comp';
            SDI1.CorporateAccIndicator__c= true;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        Test.startTest();
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    } 
    
    public static testmethod void TestInvalidAsset()
    {
        Service_Data_Import__c SDI1 = new Service_Data_Import__c();
        SDI1.Brand__c='Jaguar';
        SDI1.Business_Phone__c='1234567890';
        SDI1.City__c='Abudabi';
        SDI1.Collection_Date__c=system.today();
        SDI1.Company_Name__c='Test Comp';
        SDI1.CorporateAccIndicator__c= true;
        SDI1.Country__c='Lebanon';
        SDI1.CountryISO_Code__c='AE';
        SDI1.CurrencyIsoCode='USD';
        SDI1.Customer_Type__c='Individual';
        SDI1.Database_Reference_ID__c='test';
        SDI1.Dealer_Code_JLR__c='JLR';
        SDI1.Dms_Id__c='test';
        SDI1.DMS_Invoice_Ref_ID__c='test';
        SDI1.Email__c='test@gmail.com';
        SDI1.First_Name__c='Test';
        SDI1.Home_Phone__c='1234567890';
        SDI1.Hours_Sold__c=10;
        SDI1.Job_Booked_Date__c=system.today();
        SDI1.Mileage__c=1234;
        SDI1.Mileage_Date__c=system.today();
        SDI1.Mileage_UOM__c='Kilometers';
        SDI1.Mobile_Number__c='1234567890';
        SDI1.Model__c='Range Rover Velar';
        SDI1.Post_Code__c='12345';
        SDI1.Price_Invoice__c=300;
        SDI1.PriceLabour__c=200;
        SDI1.Price_Parts__c=300;
        SDI1.Registration_Number__c='REGLIC3';
        SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
        SDI1.Repair_Order_Number__c='1234';
        SDI1.Service_Repair_Date__c=system.today();
        SDI1.SR_Type__c='Warranty';
        SDI1.State__c='SK';
        SDI1.Status__c='Unprocessed';
        SDI1.VIN__c='ABCDEFGH1234';
        Insert SDI1;
        Test.startTest();
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    public static testmethod void TestJLRDelearCorpAccountMatch_InvalidContactData()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=corporateAccRecId;
            indCustumer.Name='Test Comp';
            indCustumer.Retailer_Email__c='test1@gmail.com';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='AE';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            indCustumer.Preferred_Sales_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test Comp';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        Test.startTest();
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    } 
    
    public static testmethod void TestJLROutsideRegion_InvalidContactData()
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
            Account retailerParentAccount = new Account();
            retailerParentAccount.Name = 'Test Account';
            retailerParentAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerParentAccount.Primary_Dealer_Code__c='JLR12';
            insert retailerParentAccount;
            
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.ParentId=retailerParentAccount.Id;
            insert retailerAccount;
            
            
            Account indCustumer= new Account();
            indCustumer.RecordTypeId=corporateAccRecId;
            indCustumer.Name='Test';
            indCustumer.Retailer_Email__c='test1@gmail.com';
            indCustumer.BillingCity='Test';
            indCustumer.BillingState='Test';
            indCustumer.BillingCountry='Dubai';
            indCustumer.Country_ISO_Code__c='EG';
            indCustumer.BillingPostalCode='873297';
            indCustumer.DMS_Identifier__c='testNew1';
            indCustumer.Owner_Retailer__c=retailerAccount.Id;
            Insert indCustumer;
            
            Contact contactForUpsert= new Contact();
            contactForUpsert.LastName='Tester';
            contactForUpsert.FirstName='Test';
            contactForUpsert.Email='test1@gmail.com';
            contactForUpsert.Email2__c='testnew@gmail.com';
            contactForUpsert.DMS_Identifier__c='87483ER';
            contactForUpsert.Title='MR';
            contactForUpsert.MobilePhone='7984938';
            contactForUpsert.HomePhone='97493843';
            contactForUpsert.AccountId=indCustumer.Id;
            contactForUpsert.OtherPhone='9749383';
            contactForUpsert.Country_ISO_Code__c='AE';
            contactForUpsert.aop_Country__c='Dubai';
            contactForUpsert.MailingCountry='Dubai';
            contactForUpsert.MailingCity='Test';
            contactForUpsert.MailingState='Test';
            contactForUpsert.MailingPostalCode='949384';
            contactForUpsert.RecordTypeId= RetailerConRecId;
            Insert contactForUpsert;
            
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
            accountForUpsert.LastName='invalid Acc';
            accountForUpsert.FirstName='Inv';
            accountForUpsert.personEmail='test1@gmail.com';
            accountForUpsert.PersonMobilePhone='94943092';
            accountForUpsert.PersonHomePhone='874394938';
            accountForUpsert.BillingCity='Test';
            accountForUpsert.BillingState='Test';
            accountForUpsert.BillingCountry='Dubai';
            accountForUpsert.Country_ISO_Code__c='AE';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew2';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Test.startTest();
            Insert accountForUpsert;
            
            AssetHandler.IgnoreMMIT=true;
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='Test';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        try{
            database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        }catch(exception e){
            
        }
        Test.stopTest();
    }
    
    public static testmethod void TestNewCorpAccounts()
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
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.Country_ISO_Code__c='AE';
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
        portalUser.FirstName = 'dummyimp';
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= true;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='I am New';
            SDI1.Last_Name__c='Different';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        Test.startTest();
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
    
    //@isTest
    public static void TestNewIndvAccounts()
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
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            retailerAccount.Country_ISO_Code__c='AE';
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
        portalUser.FirstName = 'dummyimp';
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
            
            Service_Data_Import__c SDI1 = new Service_Data_Import__c();
            SDI1.Brand__c='Jaguar';
            SDI1.Business_Phone__c='1234567890';
            SDI1.City__c='Abudabi';
            SDI1.Collection_Date__c=system.today();
            SDI1.Company_Name__c='Test';
            SDI1.CorporateAccIndicator__c= false;
            SDI1.Country__c='Lebanon';
            SDI1.CountryISO_Code__c='AE';
            SDI1.CurrencyIsoCode='USD';
            SDI1.Customer_Type__c='Individual';
            SDI1.Database_Reference_ID__c='test';
            SDI1.Dealer_Code_JLR__c='JLR';
            SDI1.Dms_Id__c='test';
            SDI1.DMS_Invoice_Ref_ID__c='test';
            SDI1.Email__c='test@gmail.com';
            SDI1.First_Name__c='I am New';
            SDI1.Last_Name__c='Different';
            SDI1.Home_Phone__c='1234567890';
            SDI1.Hours_Sold__c=10;
            SDI1.Job_Booked_Date__c=system.today();
            SDI1.Mileage__c=1234;
            SDI1.Mileage_Date__c=system.today();
            SDI1.Mileage_UOM__c='Kilometers';
            SDI1.Mobile_Number__c='1234567890';
            SDI1.Model__c='Range Rover Velar';
            SDI1.Post_Code__c='12345';
            SDI1.Price_Invoice__c=300;
            SDI1.PriceLabour__c=200;
            SDI1.Price_Parts__c=300;
            SDI1.Registration_Number__c='REGLIC3';
            SDI1.Repairing_Retailer_Name__c='Alpha Tunisie';
            SDI1.Repair_Order_Number__c='1234';
            SDI1.Service_Repair_Date__c=system.today();
            SDI1.SR_Type__c='Warranty';
            SDI1.State__c='SK';
            SDI1.Status__c='Unprocessed';
            SDI1.VIN__c='ABCDEFGH1234';
            Insert SDI1;
        }   
        Test.startTest();
        database.executeBatch(new Batch_ServiceDataImporter('AE',false));
        Test.stopTest();
    }
}