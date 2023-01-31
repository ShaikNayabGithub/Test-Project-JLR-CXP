@isTest(seeAllData=false)
public class Batch_CVoiceServiceEventExport_Test {
    
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    public static Id serviceEventRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId(); 
    public static Id serviceAppointmentRecId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Service_Appointment').getRecordTypeId(); 
    
    
    public static testmethod void TestcVoiceServiceDataExport()
    {
        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();

        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar',Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover',Translatable_Value__c = 'Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Surveys and Research', CXP_Name__c = 'Surveys and Research', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;JP',Translatable_Value__c = 'Surveys and Research'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Surveys and Research', CXP_Name__c = 'Surveys and Research', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;JP',Translatable_Value__c = 'Surveys and Research'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, CXP_Name__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;JP',Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, CXP_Name__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;JP',Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c));
        insert dupList;

        Profile systemAdmin = [select Id from Profile where Name = 'JLR System Administrator (Super)' limit 1];
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
            runningUser.Market__c = 'JP';
            runningUser.Country_ISO_Code__c='JP';
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
        Asset testasset; 
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
            accountForUpsert.BillingCountry='Japan';
            accountForUpsert.Country_ISO_Code__c='JP';
            accountForUpsert.BillingPostalCode='873297';
            accountForUpsert.DMS_Identifier__c='testNew1';
            accountForUpsert.Owner_Retailer__c=loggedinUser.AccountId;
            Insert accountForUpsert;
            DateTime todayDate = System.now();
            Date dateValue = Date.newinstance(todayDate.year(), todayDate.month(), todayDate.day());
            testasset = new Asset();
            testasset.Name = 'ABCDEFGH1234';
            testasset.AccountId = accountForUpsert.Id;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Vin__c = 'ABCDEFGH1234';
            testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            testasset.Vista_Status__c='Customer Handover';
            testasset.Handover_Date__c = dateValue.addDays(-20);
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
        }
        
        system.runAs(runningUser)
        {
            Event e = new Event();
            e.RecordTypeId=serviceAppointmentRecId;
            e.VIN_number__c=testasset.Id;
            //e.DurationInMinutes=1;
            //e.ActivityDateTime=DateTime.Now();
            e.WhatId=testasset.Id;
            e.Service_Type__c='1st Service';
            e.Who_Contact__c=testCommContact.Id;
            e.Service_Status__c='Completed';
            e.StartDateTime=System.now();
            e.EndDateTime=System.now();
            //e.Country_ISO_Code__c='JP';
            insert e;
        }
        
        Test.startTest();
        database.executeBatch(new Batch_CVoiceServiceEventExport());
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('TestSchedule', CRON_EXP, new Batch_CVoiceServiceEventExport() );
        Test.stopTest();
    }
}