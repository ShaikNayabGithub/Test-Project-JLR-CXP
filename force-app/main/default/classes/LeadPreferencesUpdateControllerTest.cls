@isTest
public class LeadPreferencesUpdateControllerTest {
    
    static testmethod void preferencesUpdateLeadTest() {
        
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Streamlined_Lead_Process').getRecordTypeId();

//        NewLead.RecordTypeId
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        Lead newLead = new Lead();
        
        
        System.RunAs(portaluser){
            newLead.FirstName = 'Sample';
            newLead.LastName = 'Test123';
            newLead.Status = 'New';
            newLead.LeadSource = 'Email';
            newLead.Email = 'sample@testmail.com';
            newLead.Enquiry_Type__c = 'Generic';           
            Insert newLead;
			LeadPreferencesUpdateController.getLead(newLead.Id);
			LeadPreferencesUpdateController.getLeadAccess(newLead.Id);
			LeadPreferencesUpdateController.getLeadLabelMap('Lead');
			LeadPreferencesUpdateController.saveLead(newLead);       
            newLead.DoNotCall = true; 
			LeadPreferencesUpdateController.saveLead(newLead);           

        }
        CXPtoCDKWrapper.inputWrapper requestPayload = new  CXPtoCDKWrapper.inputWrapper(newLead.id);
    }
	
    static testmethod void checkSpamLeads() {
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Streamlined_Lead_Process').getRecordTypeId();

//        NewLead.RecordTypeId
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        Lead newLead = new Lead();
        
        
        System.RunAs(portaluser){
            newLead.FirstName = 'Sample';
            newLead.LastName = 'Test123';
            newLead.Status = 'New';
            newLead.LeadSource = 'Email';
            newLead.Email = 'sample@testmail.com';
            newLead.Enquiry_Type__c = 'Generic';
            Insert newLead;
            newLead.LastName = 'Test';
            newLead.Email = 'sample@test.ru';
            LeadHandler ldhandler = new LeadHandler();
            ldhandler.isSpam(newLead);
            newLead.LastName = 'TesTSpam';
            newLead.Email = 'sample@test.ru';
            ldhandler = new LeadHandler();
            ldhandler.isSpam(newLead);
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
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert commUser;
        }
        return commUser;
    }

}