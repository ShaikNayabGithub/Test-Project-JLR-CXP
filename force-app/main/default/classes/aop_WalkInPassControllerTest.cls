@isTest
Public Class aop_WalkInPassControllerTest
{
    
    Public void setData()
    {
        Request__c request = New Request__c();
        CampaignMember campaignMember = New CampaignMember();
        
        Contact contact1 = New Contact();
        Contact contact2 = New Contact();
        Contact contact3 = New Contact();

        insert request;
        insert campaignMember;
        insert contact1;
        insert contact2;
        insert contact3;
    }
  
	
/* Commented as too many SOQLs   
 * static TestMethod void TestGetCampaignMembReturnsCorrectCampaignMember()
    {
        List<RecordType> preRegistrationRequestRecordTypes = [SELECT ID
                                                   			FROM RecordType
                                                   			WHERE Name =:  'Pre-Registration Request' AND sObjectType = 'Request__c'
                                                  			]; 
        
        List<RecordType> retailerRecordTypes = [SELECT ID
                                               FROM RecordType
                                               WHERE Name =:  'Retailer' AND sObjectType = 'Account'
                                              ]; 
        
        Account retailer = New Account(Name = 'TestRetailer', RecordTypeId = retailerRecordTypes[0].id, Dealer_CI_Code__c = 'x', Primary_Dealer_Code__c = 'x', Secondary_Dealer_Code__c = 'x');
            
        insert retailer;
        
        
        Request__c request = New Request__c(Last_Name__c = 'GlobalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'Germany', Language__c = 'German', 
                                                     RecordTypeId = preRegistrationRequestRecordTypes[0].id, aop_Source__c = 'Retailer', aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);
        campaign campaign = New Campaign(Name = 'TestCampaign');
        
        aop_Locale_Mapping__c localeMapGermanyGerman = New aop_Locale_Mapping__c(aop_Locale_Code__c = 'de_DE', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'de_DE', aop_Salesforce_Language__c = 'de', aop_country__c = 'Germany', aop_language__c = 'German',
                                                                                    aop_Checkfront_Language_Code__c = 'xxx');
        
        insert localeMapGermanyGerman;

        
    
        
        CampaignMember campaignMember = New CampaignMember();
        //Account acc1 = New Account(Name = 'newacc');
        
        //insert acc1;
        insert campaign;
        insert request;
        Contact contact1 = New Contact(email = 'test@test.com', lastname = 'Test');
        insert contact1;
        
        campaignMember.ContactId = contact1.id;
        campaignMember.CampaignId = campaign.id;
        insert campaignMember;

        
        aop_WalkInPassController controller = New aop_WalkInPassController();
        controller.eventReq = request;
        controller.eventReq.aop_Customer__c = contact1.id;
        controller.eventReq.Campaign__c = campaign.id;
        CampaignMember testCampaignMember = controller.getCampaignMemb();
        System.debug('campaignMember: ' + campaignMember + ' testCampaignMember: ' + testCampaignMember);
        System.assertEquals(campaignMember.id, testCampaignMember.id);
    }*/
    
    Static TestMethod void TestGetCampaignMembReturnsNullIfNoMatchCampaignMember()
    {
        aop_WalkInPassController controller = New aop_WalkInPassController();
        controller.eventReq = New Request__c();
        controller.eventReq.aop_Customer__c = '07M7E000000OXv0';
        controller.eventReq.Campaign__c = '07M7E000000OXv0';
        controller.formatDate = '09/06/1991';
        CampaignMember testCampaignMember = controller.getCampaignMemb();
        System.assertEquals(null, testCampaignMember);
    }
    
    Static TestMethod void TestgetUpperEventNameReturnsCorrectString()
    {
        Campaign campaign = New Campaign(Name = 'TestCampaign', Market_ID__c = 'IN');
        insert campaign;
        aop_WalkInPassController controller = New aop_WalkInPassController();
        controller.eventReq = New Request__c();
        controller.eventReq.Campaign__c = campaign.id;
        
        String testString = controller.getUpperEventName();
        System.assertEquals('TESTCAMPAIGN', testString);
    }
    
    Static TestMethod void TestgetFormatDateReturnsCorrectString()
    {
        aop_WalkInPassController controller = New aop_WalkInPassController();
        controller.campaignMemb = New CampaignMember();
        controller.eventRepContact = New Contact();
        controller.eventRepCampaign = New Campaign();
        controller.upperEventName = 'abc';
        controller.campaignMemb.aop_Session_Start__c = datetime.newInstance(1991, 04, 22);
		String testString = controller.getFormatDate();
        System.assertEquals('22/4/1991', testString);
       
    }
    
    Static TestMethod void TestgetFormatDateReturnsNullIfNoCampaignMember()
    {
        aop_WalkInPassController controller = New aop_WalkInPassController();
		String testString = controller.getFormatDate();
        controller.eventReq = New Request__c();
        Campaign campaign = New Campaign(Name = 'TestCampaign', Market_ID__c = 'IN');
        insert campaign;
        controller.eventReq.Campaign__c = campaign.id;
        System.assertEquals(null, testString);

    }
    
    Static TestMethod void TestgetEventRepContactReturnsMatchingContact()
    {
        Contact contact1 = New Contact(email = 'test@test.com', lastname = 'Test');
        insert contact1;
        aop_WalkInPassController controller = New aop_WalkInPassController();
        controller.eventReq = New Request__c();
        controller.eventReq.aop_Customer__c = contact1.id;
		Contact testContact = controller.getEventRepContact();
        System.assertEquals(testContact.id, contact1.id);
    }
    
    Static TestMethod void TestgetEventRepCampaignReturnsMatchingCampaign()
    {
        Campaign campaign = New Campaign(Name = 'TestCampaign', Market_ID__c = 'IN');
        insert campaign;
        aop_WalkInPassController controller = New aop_WalkInPassController();
        controller.eventReq = New Request__c();
        controller.eventReq.Campaign__c = campaign.id;
		Campaign testcampaign = controller.getEventRepCampaign();
        System.assertEquals(testcampaign.id, campaign.id);

    }
    
    
}