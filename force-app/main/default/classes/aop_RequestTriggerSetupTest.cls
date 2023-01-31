@isTest
private class aop_RequestTriggerSetupTest {

    static testMethod void TestGetRecordTypesReturnsListOfRecordTypes() {
        List<RecordType> rts = aop_RequestTriggerSetup.GetRecordTypes();
        System.assertEquals(false, rts.isEmpty());
    }
    
    static testMethod void TestGetAccountsReturnsListOfAccountsWhenMatchingAccountCreated()
    {
        Request__c evReq = new Request__c(aop_Country__c = 'United Kingdom', Preferred_Retailer_Code__c = '12345');
        aop_NationalityToISOCode__c countryMap = new aop_NationalityToISOCode__c(Name = 'United Kingdom', aop_ISO_Code__c = 'ISO', aop_Checkfront_Instance__c = 'a@b.com');
        insert countryMap;
        List<Request__c> reqList = new List<Request__c>();
        reqList.add(evReq);
        
      Account acc = new Account(Name = 'abc', Secondary_Dealer_Code__c = 'JISO12345');
      insert acc;
      List<Account> accounts = aop_RequestTriggerSetup.GetAccounts(reqList);
      System.assertEquals(false, accounts.isEmpty());
    }
    
    static testMethod void TestGetContactsReturnsListOFContactsWhenMatchingContactCreated()
    {
        
      Account acc = new Account(Name = 'abc', Secondary_Dealer_Code__c = 'abc2');
      insert acc;
      Contact con = new Contact(LastName = 'Higgins', AccountId = acc.Id, Email = 'example@example.com');
      insert con;
        Request__c evReq = new Request__c(aop_Customer__c = con.Id, aop_Country__c = 'United Kingdom', Preferred_Retailer_Code__c = '12345');
        List<Id> reqList = new List<Id>();
        reqList.add(con.Id);
      List<Contact> contacts = aop_RequestTriggerSetup.GetContacts(reqList);
      System.assertEquals(false, contacts.isEmpty());
     }
     
     static testMethod void TestGetConfigsReturnsListofAreaConfigsWhenOneIsCreated()
     {
       Id userID = UserInfo.getUserId();
       aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_Community_URL__c = 'facebook.com', aop_Community_Permission_Set__C = 'permSet', aop_New_Record_Owner__c = userID, aop_Checkfront_AOP_Id__c = '3', aop_AWS_Path__c = 'path', aop_Retailer_Queue_Name__C = 'name', aop_Customer_Queue_Name__c = 'name', aop_Spotify_Link__C = 'x.com', aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '0299', aop_NSC_Contact_Email__c = 'a@b.com', aop_Minimum_Age__C = 12, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_Token__c = 'none token');
        insert areaConfig;
        List<aop_Area_Configuration__c> areaConfigs = aop_RequestTriggerSetup.GetConfigs();
        System.assertEquals(false, areaConfigs.isEmpty());
     }
}