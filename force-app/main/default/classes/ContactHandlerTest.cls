@isTest(seeAllData=false)
public class ContactHandlerTest {
    
    static testmethod void Test1(){
        //TO DO 
        Profile prof2 = [SELECT Id FROM Profile WHERE Name = 'JLR System Administrator'];
        User newuser = new User();
        newuser.FirstName = 'Little';
        newuser.LastName = 'Man';
        newuser.Email = 'Scared@you.com';
        newuser.Country_ISO_Code__c = 'IN';
        newuser.Market__c = 'IN';
        newuser.Username = 'Lilman@yoursevice.com';
        newuser.Alias  = 'LilM';
        newuser.CommunityNickname  = 'nappy';
        newuser.TimeZoneSidKey  = 'Europe/London';
        newuser.LocaleSidKey = 'en_US';
        newuser.EmailEncodingKey = 'UTF-8';
        newuser.ProfileId  = prof2.id;
        newuser.LanguageLocaleKey = 'en_US';
        
        
        insert newuser;
        Test.startTest();
        List<Contact> lstContact= New List<Contact>();
        system.runAs(newuser)
        {
            lstContact.add(new contact (FirstName = 'Big', LastName = 'Man', Email = 'Running1@you.com', LA_Opt_In__c = 'LN',OwnerId = newuser.id));
            lstContact.add(new contact (FirstName = 'Big', LastName = 'Man', Email = 'Running2@you.com', LA_Opt_In__c = 'LY',OwnerId = newuser.id));
            lstContact.add(new contact (FirstName = 'Big', LastName = 'Man', Email = 'Running3@you.com', LA_Opt_In__c = 'JY',OwnerId = newuser.id));
            lstContact.add(new contact (FirstName = 'Big', LastName = 'Man', Email = 'Running4@you.com', LA_Opt_In__c = 'JN',OwnerId = newuser.id));
            insert lstContact;
        }
        Test.stopTest(); 
    }
}