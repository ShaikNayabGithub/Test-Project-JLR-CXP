@isTest
public class Batch_testcvoiceLostTest {
    
    @testSetup 
    static void setup(){
        
        /*Id usr = [select Id from Profile where Name='JLR System Administrator'].Id;
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ProfileId = usr,
        TimeZoneSidKey='America/Los_Angeles', Username=uniqueUserName, IsActive =true, LocaleSidKey='en_US');
        insert u;*/

        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();

        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar',Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover',Translatable_Value__c = 'Land Rover'));
        lbList.add(new DataUseLegalBasis(Name = 'Retailer',Translatable_Value__c = 'Retailer'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Surveys and Research', CXP_Name__c = 'Surveys and Research', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE',Translatable_Value__c = 'Surveys and Research'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Surveys and Research', CXP_Name__c = 'Surveys and Research', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE',Translatable_Value__c = 'Surveys and Research'));
        //dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, CXP_Name__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE',Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c));
        //dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, CXP_Name__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE',Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c));
        insert dupList;

        Account personAccount = TestClass_AccountCreator.createPersonAccount();
        personAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        personAccount.Owner_Retailer__c = '1234567';
        personAccount.Country_ISO_Code__c='AE';
        personAccount.Country_ISO_Code__pc='AE';
        personAccount.Is_Primary__c = false;
        update personAccount;
        system.Debug('@@personAccount' + personAccount);
        
        //
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        Account corpAccount = new Account(Id=opp.AccountId);
        corpAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        corpAccount.Owner_Retailer__c = '1234567';
        corpAccount.Country_ISO_Code__c='AE';
        corpAccount.Is_Primary__c = false;
        update corpAccount;
        Test.startTest();
        opp.Date_to_Order_Stage_Time__c = Date.today()- 1;
        opp.StageName = 'Lost';
        opp.Retailer_Loss_Category__c = 'Other';
        opp.Retailer_Loss_Type__c = 'Retailer Experience';
        opp.Retailer_Loss_Description__c = 'automatic close';
        insert opp;
        system.Debug('@@opp' + opp);
         
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);

      
        Asset newAsset = TestClass_AssetBuilder.BuildVehicle();
        newAsset.Vehicle_Initial_Registration_Date__c = system.today()-4;
        newAsset.AccountId=personAccount.Id;
        newAsset.Handover_Date__c = system.today()-1;
        newAsset.VIN__c = '11AABB';
        newAsset.Common_Sale_Type__c='Individual';
        newAsset.Sale_Type_Code__c='RET';
        newAsset.Type_Of_Sale_ID__c='AAA';
        insert newAsset;
        system.Debug('@@newAsset' + newAsset);
        
        OpportunityLineItem opportunity1  = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, make.Id, null);
        opportunity1.Asset__c = newAsset.Id;
        opportunity1.Brand__c = make.Id;
        insert opportunity1;
        system.Debug('@@opportunity1' + opportunity1);
        
        //consent tried
         Account acc =[select id,PersonIndividualId from Account where RecordType.Name = 'Individual' and id =:personAccount.id];
         ContactPointTypeConsent consent = new ContactPointTypeConsent();
        consent.DataUsePurposeId = dupList[0].id;
        consent.Name = 'TestConsent';
        consent.PartyId = acc.PersonIndividualId;
        consent.Retailer__c= opp.AccountId;
        consent.PrivacyConsentStatus = 'OptIn';
        consent.Channel__c = 'Email';
        insert consent; 
        system.Debug('@@consent' + consent);
        //consent end
       
        Test.stopTest();
    }
    
    public static testmethod void testScheduler() {
        Test.startTest();
        Account acc =[select id,PersonIndividualId from Account where RecordType.Name = 'Individual'];
        //in anonymous--check personindividualid,put system.debug as well for opp insert,
        system.Debug('@@acc1' + acc);
        
        //ConsentHandler.updateConsents(new List<Account>{acctIndvDetails});
		//System.debug('@oppDetails'+[Select Id from Opportunity]);
        Opportunity oppDetails = [Select Id from Opportunity];
        system.Debug('@@oppDetails' + oppDetails);
        oppDetails.AccountId = acc.Id;
        update oppDetails;
        system.Debug('@@oppDetails2' + oppDetails);

        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('TestSchedule', CRON_EXP, new Batch_CVoiceLostOpportunityExport() );
        Test.stopTest();
    } 
   
    public static testMethod void testBatchCorporateAccount() {

        Test.startTest();
        //System.debug('@oppDetails'+[Select Id from Opportunity]);
        Opportunity oppDetails = [Select Id from Opportunity];
        Account acctDetails = [Select Id  from Account where RecordType.Name = 'Corporate'];
        acctDetails.Dealer_CI_Code__c = '12345';
        acctDetails.Alternative_Key__c = 'test Corporate';
        acctDetails.BillingStreet = 'test1';
        acctDetails.BillingCity='test';
        acctDetails.BillingPostalCode='24423';
        acctDetails.BillingCountry = 'Uk';
        acctDetails.Phone = '12131313';
        acctDetails.Country_ISO_Code__c = 'AE';
        update acctDetails;

        
        Contact newContact = new Contact(
            FirstName='Joe',
            LastName='Smith',
            Phone='415.555.1212',
            Language__c = 'English (UK)',
            Gender__c = 'Male',
            Birthdate= Date.newInstance(1990, 01, 01),
            Land_Rover_Opt_Out__c = true,
            AccountId=acctDetails.Id);
        insert newContact;

        Id p = [select Id from Profile where Name='Partner Community User'].Id;
        User user = new User(Alias = 'test123', Email='test123@noemail.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p, Country='United States',IsActive =true,
                             ContactId = newContact.Id,
                             Country_ISO_Code__c = 'AE',
                             TimeZoneSidKey='America/Los_Angeles', Username='tester1@noemail.com.unittest');
        
          User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
                System.runAs(usrAdmin) {
                    insert user;
                }
        oppDetails.OwnerId = user.Id;
        update oppDetails;
        OpportunityContactRole contactRole = new OpportunityContactRole();
        contactRole.OpportunityId = oppDetails.Id;
        contactRole.ContactId = newContact.Id;
        contactRole.IsPrimary = true;
        contactRole.Role = 'Primary Contact';
        insert contactRole;
        
        Database.executeBatch(new Batch_CVoiceLostOpportunityExport(), 200);
        Test.stopTest();
        
        
    }
    
    public static testMethod void testBatchIndividualAccount() {  
        Test.startTest();  
        
        Account retailer = new Account();
        retailer.Name = 'test retailer';
        retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        retailer.Dealer_CI_Code__c = '12345';
        retailer.Country_ISO_Code__c = 'AE';
        retailer.Alternative_Key__c = 'test retailer';
        
        insert retailer;
        
        Contact newContact = new Contact(
            FirstName='Joe',
            LastName='Smith',
            Phone='415.555.1212',
            Language__c = 'English (UK)',
            Gender__c = 'Male',
            Birthdate= Date.newInstance(1990, 01, 01),
            Land_Rover_Opt_Out__c = true,
            AccountId=retailer.Id);
        insert newContact;
        
        Id p = [select Id from Profile where Name='Retailer Service Manager'].Id;
        User user = new User(Alias = 'test123', Email='test123@noemail.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p, Country='United States',IsActive =true,
                             ContactId = newContact.Id,
                             Country_ISO_Code__c = 'AE',
                             TimeZoneSidKey='America/Los_Angeles', Username='tester1@noemail.com.unittest');
        
           User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
                System.runAs(usrAdmin) {
                    insert user;
                }

        Account acctIndvDetails = [Select Id, Retailer_Id__c, PersonIndividualId, Country_ISO_Code__c, et4ae5__HasOptedOutOfMobile__pc, PersonDoNotCall, PersonHasOptedOutOfEmail, Direct_Mail_Opt_Out__pc, aop_Country__pc, LiveAgent_OptOut__c, LA_Opt_In__pc from Account where RecordType.Name = 'Individual'];
        acctIndvDetails.Pseudo_Account_Owner__c = user.Id;
        acctIndvDetails.Dealer_CI_Code__c = '12345';
        acctIndvDetails.Alternative_Key__c = 'test Corporate';
        acctIndvDetails.PersonMailingStreet = 'test2';
        acctIndvDetails.PersonMailingCity='test';
        acctIndvDetails.PersonMailingState = 'test';
        acctIndvDetails.PersonMailingPostalCode='24423';
        acctIndvDetails.PersonMailingCountry = 'Uk';
        acctIndvDetails.PersonMobilePhone = '12131313';
        acctIndvDetails.Direct_Mail_Opt_Out__pc = True;
        acctIndvDetails.PersonHasOptedOutOfEmail = True;
        acctIndvDetails.et4ae5__HasOptedOutOfMobile__pc = True;
        acctIndvDetails.Gender__pc = 'Male';
        acctIndvDetails.PersonBirthdate = Date.newInstance(1990, 01, 01);
        acctIndvDetails.PersonHomePhone = '1214235423';
        acctIndvDetails.Language__pc = 'English (UK)';
        acctIndvDetails.Country_ISO_Code__pc = 'AE';
        update acctIndvDetails;

        ConsentHandler.updateConsents(new List<Account>{acctIndvDetails});

        Opportunity oppDetails = [Select Id from Opportunity];
        oppDetails.AccountId = acctIndvDetails.Id;
        update oppDetails;
        
        Database.executeBatch(new Batch_CVoiceLostOpportunityExport(), 200);
        
        Test.stopTest();
                
    }

}


//test class