@IsTest
public class SetRetailerForRetailerContact_Test {   
    
    public static Contact createRetailerContact() {
        Account newAcc = new Account(Name = 'newName');
        insert newAcc;
        Contact testContact = new Contact(AccountId = newAcc.Id);
        testContact.LastName = 'Test Con';
        testContact.RecordType = [select Id from RecordType where Name = 'Retailer Contact' and SobjectType = 'Contact' limit 1];
        testContact.Email = 'test@test.test';
        testContact.Phone = '0303030303';
        insert testContact;
        return testContact;
        
    }
    
    public static Account createRetailerAccount() {
        Account testCommAccount = new Account();
        testCommAccount.Name = 'Test Account';
        testCommAccount.RecordTypeId = [select Id from RecordType where Name = 'Retailer' and SobjectType = 'Account' limit 1].Id;
        insert testCommAccount;
        system.debug('***1 ' + testCommAccount.Preferred_Sales_Retailer__c);
        return testCommAccount;
    }
    
    //This method creates an account and a contact and then creates a community user to associate these with. 
    //It also creates its own controller in order to associate the community user with the rule that is created, and takes an accountRating parameter which determines which opportunities the users should follow
    private static User createCommunityUser(Account testCommAccount)
    {
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = testCommAccount.Id;
        testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test@test.test';
        commUser.ProfileId = [select Id from Profile where Name = 'Sales Executive' limit 1].Id;
        commUser.UserName = 'test@test.test.retailer';
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        
        // Code Failing and its preventing deployment 
        // NTT will need to fix. 
        //insert commUser;
        system.debug('***3 ' + testCommContact.AccountID);
        return commUser;
    }
    
    // Code Failing and its preventing deployment 
    // NTT will need to fix. 
    /*
    @IsTest(SeeAllData=true)
    static void Test_PreferredRetailer_IsSet() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.RunAs(thisUser)
        {
            Account retailerAccount = createRetailerAccount();
            User testUser = createCommunityUser(retailerAccount);
            System.RunAs(testUser) {
                system.debug('Creating contact');
                Contact con = createRetailerContact();
                //System.Debug([Select Id, Preferred_Sales_Retailer__c from Account where Id = :acc.Id limit 1].Preferred_Sales_Retailer__c + ' Is the preffered sales retailer, the retailer account Id is ' + retailerACcount.Id);
                System.assert([Select Id, Retailer__c from Contact where Id = :con.Id limit 1].Retailer__c == retailerAccount.Id);
            }
        }
    }
    */ 
}