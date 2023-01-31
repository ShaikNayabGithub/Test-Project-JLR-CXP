@isTest
public class aop_RequestTriggerTest {
    static testMethod void TestInsertWalkInCreatesPersonAccount()
    {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name =: 'Walk-in' LIMIT 1];
        aop_NationalityToISOCode__C isoKey = new aop_NationalityToISOCode__c(Name = 'France');
                isoKey.aop_Checkfront_Instance__c = 'abc.com';
                //isoKey.aop_Locale_Code__c = 'FR_fr';
        insert isoKey;
        aop_Area_Configuration__c areaConfig = new aop_Area_configuration__c(aop_NSC_Contact_Phone__c = '111', aop_NSC_Contact_Email__c = 'example@exmaple.com', aop_Spotify_Link__c = 'a.com', aop_Minimum_Age__c = 1, aop_Rebooking_Window__C = 5, aop_Community_URL__C = 'abc.com', aop_Community_Permission_Set__c = 'id', aop_Checkfront_Token__C =  'abc', aop_Customer_Queue_Name__c = 'newGroup', aop_Retailer_Queue_Name__c = 'newGroup', aop_Checkfront_AOP_Id__c = 'aop', aop_AWS_Path__C = 'awspath', Name = 'France', aop_Checkfront_Instance__c = 'abc.com');
        insert areaConfig;
        Campaign camp = new Campaign(Name = 'campaign', ExpectedResponse = 90, Market_ID__c = 'IN');
        insert camp;
        Group newGroup = new Group(Name = 'newGroup');
        insert newGroup;
        
        Request__c evReq = new Request__c( Language__C = 'English', RecordTypeId = rt.Id, Campaign__c = camp.Id, aop_Country__c = 'France', aop_Source__c = 'Walk-in', First_Name__c = 'Julian', Last_Name__c = 'Grayson', Email__c = 'julain@grayson.com');
        insert evReq;
        
        List<Account> newPersons = [SELECT Id FROM Account WHERE PersonEmail = 'julain@grayson.com'];
        System.assertNotEquals(0, newPersons.size());
            
    }

}