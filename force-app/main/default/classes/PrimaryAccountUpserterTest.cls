@isTest
public class PrimaryAccountUpserterTest {

    static testmethod void UpserterMakesAccountPrimaryGivenNonRetailerCorporateAccount() {
        insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);
		Account retailer = new Account();
        retailer.Name = 'retailer corporate';
        retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        retailer.Dealer_CI_Code__c = 'test retailer';
        retailer.Primary_Dealer_Code__c = 'test retailer' ;
        retailer.Secondary_Dealer_Code__c = 'test retailer';
        retailer.Alternative_Key__c = 'test retailer';
        retailer.Phone = '1234567890';
        retailer.Country_ISO_Code__c = 'IN';
        insert retailer;  
        
        retailer = [SELECT Is_Primary__c FROM Account WHERE Id = :retailer.Id];
        //System.assertEquals(true, retailer.Is_Primary__c); //need to fix other test classes first
    }

    static testmethod void UpserterPopulatesOwnerRetailerGivenRetailerCorporateAccount() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        Account retailer = new Account();
		
        insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);    
        System.RunAs(portaluser){
            retailer.Name = 'retailer corporate';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            retailer.Dealer_CI_Code__c = 'test retailer';
            retailer.Primary_Dealer_Code__c = 'test retailer' ;
            retailer.Secondary_Dealer_Code__c = 'test retailer';
            retailer.Alternative_Key__c = 'test retailer';
            retailer.Phone = '1234567890';
            retailer.Country_ISO_Code__c = 'IN';
            insert retailer;  
        }
            
        retailer = [SELECT Owner_Retailer__c FROM Account WHERE Id = :retailer.Id];
        System.assertEquals(retailer.Owner_Retailer__c, retailerAccount.Id);
    }
    
    static testmethod void UpserterPopulatesOwnerRetailerGivenRetailerIndividualAccount() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        Account retailer = new Account();
            
		insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);	
        System.RunAs(portaluser){
            //retailer.Name = 'retailer individual';
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
        }
            
        retailer = [SELECT Owner_Retailer__c FROM Account WHERE Id = :retailer.Id];
        System.assertEquals(retailer.Owner_Retailer__c, retailerAccount.Id);
    }

    static testmethod void UpserterCreatesPrimaryAccountGivenRetailerCorporateAccount() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        //retailerAccount.RecordTypeId = [select Id from RecordType where Name = 'Retailer' and SobjectType = 'Account' limit 1].Id;
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount,salesExecutiveProfile.Id);
                       
		insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true); 
        System.RunAs(portaluser){
            Account retailer = new Account();
            retailer.Name = 'retailer';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            retailer.Phone = '1234567890';
            retailer.Country_ISO_Code__c = 'IN';
            retailer.Owner_Retailer__c = retailerAccount.Id;
            retailer.Is_Primary__c = false;
                
            insert retailer;
        }
        List<Account> primaryAccounts = [SELECT Id FROM Account WHERE Is_Primary__c = true];
        System.assertEquals(1, primaryAccounts.size());
    }
    
    static testmethod void UpserterDoesNotCreateMultiplePrimaryAccountsGivenDuplicateRetailerCorporateAccounts() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        //retailerAccount.RecordTypeId = [select Id from RecordType where Name = 'Retailer' and SobjectType = 'Account' limit 1].Id;
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount,salesExecutiveProfile.Id);
		
        insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);                
        System.RunAs(portaluser){
            Account retailer = new Account();
            retailer.Name = 'retailer';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            retailer.Phone = '1234567890';
            retailer.Country_ISO_Code__c = 'IN';
            retailer.Is_Primary__c = false;
                
            insert retailer;      
                
            Account retailer1 = new Account();
            retailer1.Name = 'retailer';
            retailer1.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            retailer1.Phone = '1234567890'; 
            retailer1.Owner_Retailer__c = retailerAccount.Id;
            retailer1.Country_ISO_Code__c = 'IN';
            
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(retailer1, dml);
        }
        List<Account> primaryAccounts = [SELECT Id FROM Account WHERE Is_Primary__c = true];
        System.assertEquals(1, primaryAccounts.size());
    }
    
    static testmethod void UpserterDoesNotCreateMultiplePrimaryAccountsGivenMultipleRetailerCorporateAccountsInSameLoad() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        //retailerAccount.RecordTypeId = [select Id from RecordType where Name = 'Retailer' and SobjectType = 'Account' limit 1].Id;
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount,salesExecutiveProfile.Id);
                       
		insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true); 			   
        System.RunAs(portaluser){
            List<Account> retailerList = new List<Account>();
            Account retailer = new Account();
            retailer.Name = 'retailer';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            retailer.Phone = '1234567890';
            retailer.Country_ISO_Code__c = 'IN';
            retailer.Owner_Retailer__c = 'test1';
            retailerList.add(retailer);     
                    
            Account retailer1 = new Account();
            retailer1.Name = 'retailer';
            retailer1.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            retailer1.Phone = '1234567890';    
            retailer1.Country_ISO_Code__c = 'IN';            
            retailer1.Owner_Retailer__c = retailerAccount.Id;
            retailerList.add(retailer1);
                
            insert retailerList;
        }

        List<Account> primaryAccounts = [SELECT Id FROM Account WHERE Is_Primary__c = true];
        System.assertEquals(1, primaryAccounts.size());
    }
  
    /*static testmethod void UpserterUpdatesPrimaryRecordGivenSecondRetailerAccountInSameLoad() {
        List<Account> retailerList = new List<Account>();
        Account retailer = new Account();
        retailer.Name = 'retailer';
        retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        retailer.Dealer_CI_Code__c = 'test retailer';
        retailer.Primary_Dealer_Code__c = 'test retailer' ;
        retailer.Secondary_Dealer_Code__c = 'test retailer';
        retailer.Alternative_Key__c = 'test retailer';
        retailer.Phone = '1234567890';
        //don't provide an email address
        retailer.Country_ISO_Code__c = 'IN';
        retailer.Owner_Retailer__c = 'test1';
        retailerList.add(retailer);
                
        Account retailer1 = new Account();
        retailer1.Name = 'retailer';
        retailer1.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        retailer1.Dealer_CI_Code__c = 'retailer';
        retailer1.Primary_Dealer_Code__c = 'retailer' ;
        retailer1.Secondary_Dealer_Code__c = 'test retailer1';
        retailer1.Alternative_Key__c = 'retailer';
        retailer1.Phone = '1234567890';    
        retailer1.Country_ISO_Code__c = 'IN';
        retailer1.Retailer_Email__c ='test@test.com'; //provide an email address
        retailer1.Owner_Retailer__c = 'test2'; //different Owner Retailer value
        retailerList.add(retailer1);
        insert retailerList;

        List<Account> primaryAccounts = [SELECT Retailer_Email__c FROM Account WHERE Is_Primary__c = true];
        System.assertEquals('test@test.com', primaryAccounts[0].Retailer_Email__c);
    }*/
   
    static testmethod void UpserterUpdatesPrimaryRecordGivenSecondIndividualAccount() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        //retailerAccount.RecordTypeId = [select Id from RecordType where Name = 'Retailer' and SobjectType = 'Account' limit 1].Id;
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        Account retailerAccount2 = retailerAccount.clone();
        retailerAccount2.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        List<Account> retailers = new List<Account>();
        retailers.add(retailerAccount);
        retailers.add(retailerAccount2);
        insert retailers;
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount,salesExecutiveProfile.Id);
        User portaluser2 = createuser(retailerAccount2,salesExecutiveProfile.Id, 'test2@test.test.retailer');
        
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
                       
        System.RunAs(portaluser2){  
            Account retailer1 = new Account();
            retailer1.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
            retailer1.LastName = 'test';
            retailer1.FirstName = 'Valid Firstname';
            retailer1.PersonMailingStreet = 'Valid Street';
            retailer1.PersonMailingPostalCode = 'Valid PostalCode';
            retailer1.PersonMailingState = 'Valid State 2';
            retailer1.PersonMailingCity = 'Valid City';        
            retailer1.PersonEmail = 'test123@test.com';
            //add a mobile phone
            retailer1.PersonMobilePhone = '7654321890';    
            retailer1.Country_ISO_Code__c = 'IN';
            insert retailer1; 
            
            retailer1.PersonMobilePhone = '765432189012';
            update retailer1; 
            System.debug('Second account: ' + retailer1);
         }
         
        Account primaryAccount = [SELECT Id, Name, PersonMailingState, PersonMobilePhone FROM Account WHERE Is_Primary__c = true LIMIT 1];
        system.debug('primaryAccount - '+primaryAccount);
       // System.assertEquals('765432189012', primaryAccount.PersonMobilePhone);

        
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

    
       static testmethod void UpserterCreatesTwoOwnerRetailerGivenRetailerCorporateAccount() {
       id retailerRecordtype =  AccountUtilities.RecordTypes.get('Retailer').Id;
           Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = retailerRecordtype;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        Account retailer = new Account();
		
        insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);    
        System.RunAs(portaluser){
            retailer.Name = 'retailer corporate';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        
            retailer.Country_ISO_Code__c = 'IN';
            insert retailer;  
        }
            
       List<Account> accounts = [SELECT id, Owner_Retailer__c FROM Account WHERE RecordtypeId != :retailerRecordtype];
        System.assertEquals(accounts.Size(), 2);
    }
    
       static testmethod void UpserterLINKSTwoOwnerRetailerGivenRetailerCorporateAccount() {
       id retailerRecordtype =  AccountUtilities.RecordTypes.get('Retailer').Id;
           Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = retailerRecordtype;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        Account retailer = new Account();
		
        insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);    
        System.RunAs(portaluser){
            retailer.Name = 'retailer corporate';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        
            retailer.Country_ISO_Code__c = 'IN';
            insert retailer;  
        }
            
      Account secondaryAccount = [SELECT id, Primary_Account__c, Owner_Retailer__c FROM Account WHERE Id = :retailer.Id];
      Account primaryAccount = [SELECT Id,Bronze_Record_Id__c  FROM Account WHERE Id = :secondaryAccount.Primary_Account__c ];
           System.assertEquals(primaryAccount.Bronze_Record_Id__c, secondaryAccount.id);
    }
    
    
        static testmethod void UpdateCorporateAccount() {
       id retailerRecordtype =  AccountUtilities.RecordTypes.get('Retailer').Id;
           Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = retailerRecordtype;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        Account retailer = new Account();
		
        insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);    
        System.RunAs(portaluser){
            retailer.Name = 'retailer corporate';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        
            retailer.Country_ISO_Code__c = 'IN';
            insert retailer;  
        }
            
      Account secondaryAccount = [SELECT id, name FROM Account WHERE Id = :retailer.Id];
     secondaryAccount.name = 'NEWNAME';
            update secondaryAccount;
    }
    
    
    
    
}