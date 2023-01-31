@isTest
public class aop_EvReqTriggerContactHandlerTest {
   static Contact CreateTestContact()
    {
        Contact newContact = new Contact(LastName = 'Harrison', Email = 'x@y.com');
        insert newContact;
        return newContact;
    }
    
    static TestMethod void TestPopulateExistingContactPopulatesContact()
    {
        Request__c request = new Request__C(Last_Name__c = 'Harrison', First_Name__C = 'Barney', Email__C = 'x@y.com');
        Contact newContact = CreateTestContact();        
        List<Contact> contactList = new List<Contact>();
        contactList.add(newContact);
        aop_EventRequestTriggerContactHandler businessLogic = new aop_EventRequestTriggerContactHandler();
        Request__C eventReq =  businessLogic.PopulateExistingContact(request, contactList);
        
        System.assertEquals(newContact.Id, eventReq.aop_Customer__c);
         
    }
    
    static TestMethod void TestPopulateExistingContactLeavesContactIfNotNull()
    {
        Contact newContact = CreateTestContact();
        List<Contact> contactList = new List<Contact>();
        contactList.add(newContact);
        Request__c request = new Request__C(Last_Name__c = 'Vernon', First_Name__C = 'Stewart', Email__C = 'x@y.com', aop_Customer__c = newContact.Id);
        
        aop_EventRequestTriggerContactHandler businessLogic = new aop_EventRequestTriggerContactHandler();
        Request__C eventReq =  businessLogic.PopulateExistingContact(request, contactList);
        
        System.assertEquals(newContact.Id, eventReq.aop_Customer__c);
         
    }
    
    static TestMethod void TestSetNewOwnerExitsIfNoNationality()
    {
        Request__c request = new Request__C(Last_Name__c = 'Vernon', First_Name__C = 'Stewart', Email__C = 'x@y.com');
        List<aop_Area_Configuration__C> areaConfigs = new List<aop_Area_Configuration__c>();
        
        aop_EventRequestTriggerContactHandler businessLogic = new aop_EventRequestTriggerContactHandler();
        Request__C eventReq =  businessLogic.SetNewOwner(request, areaConfigs);
        
        System.assertEquals(eventReq.OwnerId, null);
         
    }
    
    static TestMethod void TestSetNewOwnerSetsOwner()
    {
        /*
        Request__c request = new Request__C(Last_Name__c = 'Vernon', First_Name__C = 'Stewart', Email__C = 'x@y.com', aop_Country__c = 'France'); // ,aop_Nationality__c = 'British'
        aop_NationalityToISOCode__C isoKey = new aop_NationalityToISOCode__c(Name = 'France');
       // isoKey.aop_Nationality__c  = 'British';
        isoKey.aop_Checkfront_Instance__c = 'abc.com';
        insert isoKey;
        
        List<Profile> profiles = [SELECT Id FROM Profile];
        Profile prof = profiles[0];
        
        User newUser = new User(Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US');
        insert newUser;
        System.debug('User ' + newUser.Id);
        
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Retailer_Queue_Name__c = 'QName', aop_Customer_Queue_Name__c = 'QNAme', aop_Spotify_Link__c = 'www.spotify.com', aop_Minimum_Age__c = 17, aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '028282', aop_NSC_Contact_Email__c = 'x@yz.com', aop_Community_URL__c = 'a@b.com', aop_Community_Permission_Set__C = 'permid', aop_Checkfront_Token__C = 'token',  aop_AWS_Path__c = 'path', aop_New_Record_Owner__c = newUser.Id, aop_Checkfront_Instance__c = 'abc.com', aop_Checkfront_AOP_Id__c = 'Ban');
        insert eventConfig;
        List<aop_Area_Configuration__c>  areaConfigs = new List<aop_Area_Configuration__C>();
        areaConfigs.add(eventConfig);
        
        System.debug('config user ' + eventConfig.aop_New_Record_Owner__c);
        
        aop_EventRequestTriggerContactHandler businessLogic = new aop_EventRequestTriggerContactHandler();
        Request__C eventReq =  businessLogic.SetNewOwner(request, areaConfigs);
        
        System.assertEquals(eventReq.OwnerId, newUser.Id);
*/
         
    }
    
    static TestMethod void TestSetRequestFieldsFromContactResetsNamesEmailOnRequest()
    {
        Account acc = new Account(Name = 'newAcc');
        insert acc;
        Contact con = new Contact(AccountId = acc.Id, FirstName = 'Hilary', LastName = 'Duff', Email = 'hilary@duff.com');
        insert con;
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Request__c evReq = new Request__c(First_Name__c = 'Lindsay', Last_Name__C = 'Lohan', Email__C = 'lindsay@lohan.com', aop_Customer__c = con.Id);
        
        aop_EventRequestTriggerContactHandler businessLogic = new aop_EventRequestTriggerContactHandler();
        evReq = businessLogic.SetRequestFieldsFromContact(evReq, contactList);
        
        System.AssertEquals('Hilary', evReq.First_Name__c);
        System.AssertEquals('Duff', evReq.Last_Name__c);
        System.AssertEquals('hilary@duff.com', evReq.Email__c);
    }
    

}