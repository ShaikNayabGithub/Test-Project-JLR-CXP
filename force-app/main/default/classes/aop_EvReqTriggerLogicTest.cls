@isTest
public class aop_EvReqTriggerLogicTest {
   static void SetupEventConfigAndCountryMap()
    {
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Retailer_Queue_Name__c = 'QName', aop_Customer_Queue_Name__c = 'QNAme', aop_Spotify_Link__c = 'www.spotify.com', aop_Minimum_Age__c = 17, aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '028282', aop_NSC_Contact_Email__c = 'x@yz.com', aop_Community_URL__c = 'a@b.com', aop_Community_Permission_Set__C = 'permid', aop_Checkfront_Token__C = 'token',  aop_AWS_Path__c = 'path', aop_Checkfront_Instance__c = 'a@b.com', aop_Checkfront_AOP_Id__c = 'Ban');
        insert eventConfig;
        aop_NationalityToISOCode__c countryMap = new aop_NationalityToISOCode__c(Name = 'France', aop_Checkfront_Instance__c = 'a@b.com', aop_ISO_Code__c = 'TE');
        insert countryMap;
        Group custQueue = new Group(Name = 'CustGroup');
        insert custQueue;
    }
    
    static TestMethod void TestHandleEventRequestContactCallsPopulateExistingContact()
    {
        SetupEventConfigAndCountryMap();
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Request__c' AND Name = 'Walk-In' LIMIT 1];
        Request__c evReq = new Request__c(aop_Country__c = 'France', aop_Status__c = 'Submitted', aop_Source__c = 'Walk-in', RecordTypeId = rt.Id, Last_Name__c = 'LastName', Email__c = 'Email@email.email');
        Contact con = new Contact(LastName = 'LastName', Email = 'Email@email.email');
        insert con;
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        List<aop_area_Configuration__c> configList = new List<Aop_Area_Configuration__c>();
        
        aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
      	Request__c result = logic.HandleEventRequestContact(evReq, conList, configList);  
       System.assertEquals(con.Id, result.aop_Customer__c);
    }
    
    static TestMethod void TestIsAOPRequestReturnsTrueIfRTIsNotDMS()
    {
        List<RecordType> rts = [SELECT Id, DeveloperName, sObjectType, Name FROM RecordType WHERE SoBjectType = 'Request__c' AND Name = 'Walk-In' LIMIT 1];
        List<RecordType> rtDMS = [SELECT Id, DeveloperName, sObjectType, Name FROM RecordType WHERE DeveloperName = 'Avoka_Request' AND sObjectType ='Request__C' LIMIT 1];
        
        Request__c evReq = new Request__c(aop_Status__c = 'Submitted', aop_Source__c = 'Walk-in', RecordTypeId = rts[0].Id, Last_Name__c = 'LastName', Email__c = 'Email@email.email');
       
        boolean result =  aop_EventRequestTriggerLogic.IsAOPRequest(evReq, rts);
        
        System.assertEquals(true, result);    
    }
    
    static TestMethod void TestIsAOPRequestReturnsFalseIfRTIsDMS()
    {
        List<RecordType> rts = [SELECT Id, DeveloperName, sObjectType, Name FROM RecordType WHERE DeveloperName = 'Avoka_Request' AND sObjectType ='Request__C' LIMIT 1];
        Request__c evReq = new Request__c(RecordTypeId = rts[0].Id, aop_Status__c = 'Submitted', aop_Source__c = 'Walk-in',  Last_Name__c = 'LastName', Email__c = 'Email@email.email');
       
        boolean result =  aop_EventRequestTriggerLogic.IsAOPRequest(evReq, rts);
        
        System.assertEquals(false, result);    
    }
    
    static TestMethod void TestHandleWalkInCreatesNewCampaignMemberCustomerNotNull()
    {
        Contact con = new Contact(LastName = 'LastName', Email = 'Email@email.email');
        Campaign cam = new Campaign(Name = 'TestCamp', ExpectedResponse = 2, Market_ID__c = 'IN');
        List<sObject> toInsert = new List<sObject>();
        toInsert.add(con);
        toInsert.add(cam);
        insert toInsert;
        RecordType rt = [SELECT DeveloperName, Id, Name FROM RecordType WHERE DeveloperName = 'Avoka_Request' AND sObjectType ='Request__C' LIMIT 1];
        Request__c evReq = new Request__c(Campaign__c = cam.Id, aop_Customer__c = con.Id, RecordTypeId = rt.Id, aop_Status__c = 'Submitted', aop_Source__c = 'Walk-in',  Last_Name__c = 'LastName', Email__c = 'Email@email.email');
       
        aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
        List<RecordType> recordTypes = new List<RecordType>(); 
        List<aop_Area_Configuration__c> areaConfigs = new List<aop_Area_Configuration__c>();
        logic.HandleWalkIn(evReq, recordTypes, areaConfigs);
        CampaignMember campMem = [SELECT Id FROM CampaignMember WHERE ContactId =: con.Id AND CampaignId =: cam.Id LIMIT 1];
        
        System.assertNotEquals(null, campMem);
    }
    
    static TestMethod void TestHandleWalkInCreatesNewCampaignMemberCustomerNull()
    {
        SetupEventConfigAndCountryMap();
        Campaign cam = new Campaign(Name = 'TestCamp', ExpectedResponse = 2, Market_ID__c = 'IN');
        insert cam;
        RecordType rt = [SELECT Id, DeveloperName, Name FROM RecordType WHERE DeveloperName = 'Avoka_Request' AND sObjectType ='Request__C' LIMIT 1];
        List<RecordType> rts = new List<RecordType>();
        List<aop_Area_Configuration__c> areaConfigs = new List<aop_Area_Configuration__c>();
        rts.add(rt);
        
        Request__c evReq = new Request__c(aop_Country__c = 'France', Campaign__c = cam.Id, RecordTypeId = rt.Id, aop_Status__c = 'Submitted', aop_Source__c = 'Walk-in',  Last_Name__c = 'LastName', Email__c = 'Email@email.email');
       
        aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
        logic.HandleWalkIn(evReq, rts, areaConfigs);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'LastName' LIMIT 1];
        CampaignMember campMem = [SELECT Id FROM CampaignMember WHERE ContactId =: acc.PersonContactId AND CampaignId =: cam.Id LIMIT 1];
        
        System.assertNotEquals(null, acc);
        System.assertNotEquals(null, campMem);
    }
    
    static TestMethod void TestSetContactQualifiedSetsIsQualifiedToTrue()
    {
        Account acc = new Account(Name = 'Barry');
        insert acc;
        Contact con = new Contact(LastName = 'Paul', AccountId = acc.Id, Email = 'paul@barry.com');
        insert con;
        
        Request__c evReq = new Request__c(aop_Status__c  = 'Qualified', aop_Customer__c = con.Id);
        aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
        
        logic.SetContactQualified(evReq);
        
        contact updateCon = [SELECT aop_Is_Qualified_for_Events__c FROM Contact WHERE Id =: con.Id LIMIT 1];
        System.assert(updateCon.aop_Is_Qualified_for_Events__c);
        
    }
    
    static TestMethod void TestHandleNoQualificationNeededDoesntUpdateReqIfNoUser()
    {
        Account acc = new Account(Name = 'Barry');
        insert acc;
        Contact con = new Contact(LastName = 'Paul', AccountId = acc.Id, Email = 'paul@barry.com');
        insert con;
        
        Request__c evReq = new Request__c(aop_Status__c  = 'Submitted', aop_Customer__c = con.Id);
        
        aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
        evReq = logic.HandleNoQualificationNeeded(evReq);
        
        System.assertEquals('Submitted', evReq.aop_Status__c);
        
    }
    
    static TestMethod void HandleWalkInCreatesCampaignMemberForKnownContact()
    {
        Account acc = new Account(Name = 'Barry');
        insert acc;
        Contact con = new Contact(LastName = 'Paul', AccountId = acc.Id, Email = 'paul@barry.com');
        Campaign cam = new Campaign(Name = 'TestCamp', ExpectedResponse = 2, Market_ID__c = 'IN');
        insert con;
        insert cam;
        
        Request__c evReq = new Request__c(Campaign__c = cam.Id, aop_Source__c = 'Walk-In', aop_Customer__c = con.Id);
        aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
        List<RecordType> rts = new List<RecordType>();
        List<aop_Area_Configuration__c> areaConfigs = new List<aop_Area_Configuration__c>();
        
        logic.HandleWalkIn(evReq, rts, areaConfigs);
        CampaignMember campMem = [SELECT Id FROM CampaignMember WHERE ContactId =: con.Id AND CampaignId =: cam.Id];
        
        System.assertNotEquals(null, campMem);
    }
    
    static TestMethod void HandlePersonAccountCreationExitsIfCustomerPopulated()
    {
        Request__c evReq = new Request__c(Last_Name__c = 'GlobalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'France', Language__c = 'German', 
                                                      aop_Source__c = 'Retailer', aop_Status__c = 'Qualified', aop_Event_Type__c = 'AOP Request');
		 List<RecordType> rts = new List<RecordType>();
		 aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Retailer_Queue_Name__c = 'QName', aop_Customer_Queue_Name__c = 'QNAme', aop_Spotify_Link__c = 'www.spotify.com', aop_Minimum_Age__c = 17, aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '028282', aop_NSC_Contact_Email__c = 'x@yz.com', aop_Community_URL__c = 'a@b.com', aop_Community_Permission_Set__C = 'permid', aop_Checkfront_Token__C = 'token',  aop_AWS_Path__c = 'path', aop_Checkfront_Instance__c = 'a@b.com', aop_Checkfront_AOP_Id__c = 'Ban');
		 List<aop_Area_Configuration__c> areaConfigs = new List<aop_Area_Configuration__c>();
		 areaConfigs.add(eventConfig);
		 aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
         evReq = logic.HandlePersonAccountCreation(evReq, rts, areaConfigs);
        
        System.assertNotEquals(null, evReq.aop_Customer__c);
        
        
    }

    static testMethod void TestSetLeftQueueTimeTowNowSetsTime()
    {
    	SetupEventConfigAndCountryMap();
        Campaign cam = new Campaign(Name = 'TestCamp', ExpectedResponse = 2, Market_ID__c = 'IN');
        Contact con = new Contact(LastName = 'LastName', Email = 'email@email.email');
        insert con;
        insert cam;
        RecordType rt = [SELECT DeveloperName, Id FROM RecordType WHERE Name = 'Walk-in' AND sObjectType ='Request__C' LIMIT 1];
        Request__c evReq = new Request__c(aop_Customer__c = con.Id, aop_Country__c = 'France', Language__c = 'English', Campaign__C = cam.Id, RecordTypeId = rt.Id, aop_Status__c = 'Qualified', aop_Source__c = 'Walk-in',  Last_Name__c = 'LastName', Email__c = 'Email@email.email');
        insert evReq;
        evReq = [SELECT CreatedDate, aop_Time_Left_In_Queue__c FROM Request__C  Where Id =: evReq.Id];
        system.debug(evReq.CreatedDate);
    	aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
    	
    	evReq = logic.setLeftQueueTimeToNow(evReq);
    	
    	system.assertNotEquals(null, evReq.aop_Time_Left_In_Queue__c);
    }

	static testMethod void TestIsUpdateQueueRemovalReturnsFalseIfRandomListPassedIn()
	{
		aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Retailer_Queue_Name__c = 'QName', aop_Customer_Queue_Name__c = 'QNAme', aop_Spotify_Link__c = 'www.spotify.com', aop_Minimum_Age__c = 17, aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '028282', aop_NSC_Contact_Email__c = 'x@yz.com', aop_Community_URL__c = 'a@b.com', aop_Community_Permission_Set__C = 'permid', aop_Checkfront_Token__C = 'token',  aop_AWS_Path__c = 'path', aop_Checkfront_Instance__c = 'a@b.com', aop_Checkfront_AOP_Id__c = 'Ban');
        insert eventConfig;
        aop_NationalityToISOCode__c countryMap = new aop_NationalityToISOCode__c(Name = 'Britain', aop_Checkfront_Instance__c = 'a@b.com', aop_ISO_Code__c = 'TE');
        insert countryMap;
        aop_Locale_Mapping__c localeMapFranceFrance = new aop_Locale_Mapping__c(aop_Locale_Code__C = 'fr_FR', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'fr_FR', aop_Salesforce_Language__c = 'fr', aop_country__c = 'France', aop_language__c = 'French',
                                                                                   aop_Checkfront_Language_Code__c = 'xxx');
		Campaign cam = new Campaign(Name = 'TestCamp', ExpectedResponse = 2, Market_ID__c = 'IN');
        Contact con = new Contact(LastName = 'LastName', Email = 'email@email.email');
        Contact cont = new Contact(LastName = 'LastName1', Email = 'email1@email.email');
        Contact conta = new Contact(LastName = 'LastName2', Email = 'email2@email.email');
        List<Contact> cons = new List<Contact>();
        cons.add(con);
        cons.add(conta);
        cons.add(cont);
        
        insert cons;
        //insert conta;
        //insert cont;
        insert cam;
		RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Walk-in' AND sObjectType ='Request__C' LIMIT 1];
        Request__c evReq = new Request__c(aop_Customer__c = con.Id, aop_Country__c = 'France', Language__c = 'French', Campaign__C = cam.Id, RecordTypeId = rt.Id, aop_Status__c = 'Qualified', aop_Source__c = 'Walk-in',  Last_Name__c = 'LastName', Email__c = 'Email@email.email');
        Request__c evRequ = new Request__c(aop_Customer__c = cont.Id, aop_Country__c = 'France', Language__c = 'French', Campaign__C = cam.Id, RecordTypeId = rt.Id, aop_Status__c = 'Qualified', aop_Source__c = 'Walk-in',  Last_Name__c = 'LastName', Email__c = 'Email@email.email');
        Request__c evReque = new Request__c(aop_Customer__c = conta.Id, aop_Country__c = 'France', Language__c = 'French', Campaign__C = cam.Id, RecordTypeId = rt.Id, aop_Status__c = 'Qualified', aop_Source__c = 'Walk-in',  Last_Name__c = 'LastName', Email__c = 'Email@email.email');
        insert evReq;
        insert evRequ;
        insert evReque;
        List<Request__c> toPass = new List<Request__C>();
        toPass.add(evRequ);
        toPass.add(evReque);
        
        aop_EventRequestTriggerLogic logic = new aop_EventRequestTriggerLogic();
        boolean result = logic.IsUpdateQueueRemoval(evReq, toPass);
        
        System.assertEquals(false, result);
	}


}