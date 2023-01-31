@isTest
public class AccountPreferencesUpdateControllerTest {
    static testmethod void preferencesUpdateOnPreInsertTest() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        Account retailer = new Account();
        
        System.RunAs(portaluser){
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
            retailer.LastName = 'test';
            retailer.FirstName = 'Valid Firstname';
            retailer.PersonMailingStreet = 'Valid Street';
            retailer.PersonMailingPostalCode = 'Valid PostalCode';
            retailer.PersonMailingState = 'Valid State';
            retailer.PersonMailingCity = 'Valid City';        
            retailer.PersonEmail = 'test@test.com';      
            retailer.Country_ISO_Code__c = 'IN';       
            retailer.Deceased_Date__pc = system.today();        
            retailer.Confirm_Deceased__pc = true;            
            insert retailer;
			AccountPreferencesUpdateController.getAccount(retailer.Id);
			AccountPreferencesUpdateController.getAccountAccess(retailer.Id);
			AccountPreferencesUpdateController.getAccountLabelMap('Account');
			AccountPreferencesUpdateController.saveAccount(retailer);       
            retailer.Jaguar_SMS_Opt_Out__pc = false; 
			AccountPreferencesUpdateController.saveAccount(retailer);  

        }
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
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
       
        commUser.Phone = '07681102495';
        commUser.Email = 'test@test.test';
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
        insert commUser;
                }
        return commUser;
    }
}