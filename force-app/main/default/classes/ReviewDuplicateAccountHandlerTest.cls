@isTest
public class ReviewDuplicateAccountHandlerTest {
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    static testMethod void method1() {
        User portalUser = TestUtility.createPortaluser('India', 'Sales Executive');
        
        System.RunAs(portaluser) {
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, ContactId, CurrencyIsoCode, Country, Market__c, Country_ISO_Code__c   
                                 FROM User 
                                 WHERE Id = :UserInfo.getUserId() 
                                 AND ContactId != null];             
            
            // Create an Account
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test', FirstName = 'Valid Firstname', PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'IN';  
            account.Is_Primary__c = false;
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            // Prepare list of email addresses
            Set < String > emailAddresses = new Set < String > ();
            emailAddresses.add('testEmailAddress@test.com');
            
            Test.startTest();
            Review_Duplicate_Account_Email__c obj = new Review_Duplicate_Account_Email__c();
            obj.Email_Actioned_User__c = loggedinUser.Id;
            obj.Market__c = loggedinUser.Market__c;
            obj.Country__c = loggedinUser.Country_ISO_Code__c;
            obj.Email_Body__c = JSON.serializePretty(new List < Account > {account}); 
            obj.Recepient_Email_Address__c = JSON.serializePretty(emailAddresses);            
            insert obj;
            Test.stopTest();
            
        }
    }
}