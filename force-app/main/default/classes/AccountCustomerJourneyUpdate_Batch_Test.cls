@isTest
public class AccountCustomerJourneyUpdate_Batch_Test {
    @testSetup static void testSetupMethod() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        //retailerAccount.RecordTypeId = [select Id from RecordType where Name = 'Retailer' and SobjectType = 'Account' limit 1].Id;
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        //Account retailerAccount2 = retailerAccount.clone();
        //retailerAccount2.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        List<Account> retailers = new List<Account>();
        retailers.add(retailerAccount);
        //retailers.add(retailerAccount2);
        insert retailers;
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount,salesExecutiveProfile.Id);
        
        insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);
        
        System.RunAs(portaluser){
            Account retailer = new Account();
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
            retailer.LastName = 'test';
            retailer.FirstName = 'Valid Firstname';
            retailer.PersonMailingStreet = 'Valid Street';
            retailer.PersonMailingPostalCode = 'Valid PostalCode';
            retailer.PersonMailingState = 'Valid State';
            retailer.PersonMailingCity = 'Valid City';        
            retailer.PersonEmail = 'test123@test.com';      
            retailer.Country_ISO_Code__c = 'IN';
            insert retailer;
            System.debug('First Account: ' + retailer);
            
            
        }
    }
    
    @isTest
    static void CreateOppForIndividualAccount() {
        User partneruser = [Select Id from User where UserType = 'PowerPartner' AND UserName = 'test@test.test.retailer'];
        Account acc = [Select Id from Account where FirstName = 'Valid Firstname' AND Is_Primary__c = false];
        Test.startTest();
        System.runAs(partneruser){
            Case caseRec = TestClass_CaseCreator.CreateCRC(acc);
            Opportunity opp = new Opportunity();
            opp.Name = 'Customer Journey Test Opp';
            opp.StageName = 'Contacted';
            opp.LeadSource = 'UDAAN';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today();
            //opp.Product__c = asset.Model__c;
            insert opp;
        }

        Opportunity opp = [select id, AccountId,Account.Record_Type_Name__c from opportunity where Name='Customer Journey Test Opp' limit 1];
        List<Account> accList = new List<Account>();
        for(Account accIns : [SELECT Id, Customer_Journey_Stage__c, RecordTypeId, Country_ISO_Code__c, Create_Golden_Record__c FROM Account WHERE Id=:opp.AccountId]){
            System.debug('AccIns CustomerJourneyStage: '+accIns.Customer_Journey_Stage__c);
            accIns.Customer_Journey_Stage__c = null;
            accIns.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            accIns.Create_Golden_Record__c = false;
            accList.add(accIns);
        }
        
        update accList;
        system.debug('accList == > '+json.serializePretty(accList));
        system.debug('AccList == > '+accList);
        Database.executeBatch( new AccountCustomerJourneyUpdate_Batch('IN'),10);
        Test.stopTest();
    }
    
    private static User createuser(Account testCommAccount, Id profileId){
        return createuser(testCommAccount, profileId, 'test@test.test.retailer');
    }
    
    private static User createuser(Account testCommAccount,Id profileId,String userUsername)
    {
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = testCommAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test123@test.test';
        commUser.ProfileId = profileId;
        commUser.UserName = userUsername;
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        commUser.Market__c = 'IN';
        commUser.Country_ISO_Code__c = 'IN';
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert commUser;
        }
        return commUser;
    }
    
    @isTest
    static void CreateOppEnjoy() {
        User partneruser = [Select Id from User where UserType = 'PowerPartner' AND UserName = 'test@test.test.retailer'];
        Account acc = [Select Id from Account where FirstName = 'Valid Firstname' AND Is_Primary__c = false];
        Test.startTest();
        System.runAs(partneruser){
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Customer Journey Test Opp';
            opp.StageName = 'Contacted';
            opp.LeadSource = 'UDAAN';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today();
            //opp.Product__c = asset.Model__c;
            insert opp;
        }

        Opportunity opp = [select id, AccountId,Account.Record_Type_Name__c from opportunity where Name='Customer Journey Test Opp' limit 1];
        List<Account> accList = new List<Account>();
        for(Account accIns : [SELECT Id, Customer_Journey_Stage__c, RecordTypeId, Country_ISO_Code__c, Create_Golden_Record__c FROM Account WHERE Id=:opp.AccountId]){
            System.debug('AccIns CustomerJourneyStage: '+accIns.Customer_Journey_Stage__c);
            accIns.Customer_Journey_Stage__c = null;
            accIns.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            accIns.Create_Golden_Record__c = false;
            accList.add(accIns);
        }
        
        update accList;
        system.debug('accList == > '+json.serializePretty(accList));
        system.debug('AccList == > '+accList);
        Database.executeBatch( new AccountCustomerJourneyUpdate_Batch('IN'),10);
        Test.stopTest();
    }
    
}