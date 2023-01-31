@isTest
public with sharing class CustomerRegistrationFlowCont_Tests {
    
    @isTest 
    public static void  Test_getRetailerCampaigns() {
        Test.startTest();
        CustomerRegistrationFlowController.getRetailerCampaigns();
        Test.stopTest();
    }

    @isTest 
    public static void  Test_getVechicleSpecificationData() {
        Test.startTest();
        CustomerRegistrationFlowController.getVechicleSpecificationData();
        Test.stopTest();
    }

    @isTest 
    public static void  Test_getCampaignMembers() {
        String myCampaignId = '1234';
        Test.startTest();
        CustomerRegistrationFlowController.getCampaignMembers(myCampaignId);
        Test.stopTest();
    }

    @isTest 
    public static void  Test_searchCampaignMembers_searchesWithNullCampaignId() {
        String myCampaignId;
        String searchTerm = 'Bloggs';
        Test.startTest();
        CustomerRegistrationFlowController.searchCampaignMembers(myCampaignId, searchTerm);
        Test.stopTest();
    }

    @isTest 
    public static void  Test_searchCampaignMembers_searchesWithGivenCampaignId() {
        String myCampaignId = 'MyCampaignId';
        String searchTerm = 'Bloggs';
        Test.startTest();
        CustomerRegistrationFlowController.searchCampaignMembers(myCampaignId, searchTerm);
        Test.stopTest();
    }

    @isTest 
    public static void  Test_getRetailerData() {
        String myCampaignId;
        String searchTerm = 'Bloggs';
        Test.startTest();
        String retailerData = CustomerRegistrationFlowController.getRetailerData();
        Test.stopTest();

        Assert.isNotNull(retailerData);
    }

    @isTest 
    public static void Test_insertLead() {
        String leadData = '{"LastName": "myLeadTest", "MobilePhone": "0888888888", "Country_ISO_Code__c": "KR" }';
        Test.startTest();
        Id myLeadId = CustomerRegistrationFlowController.insertLead(leadData);
        Test.stopTest();
        List<Lead> leads = [SELECT Id FROM Lead WHERE Id = :myLeadId];

        System.assertEquals(1, leads.size());
    }

    @isTest 
    public static void Test_setCampaignMemberAsResponded() {
        Account secondaryIndvidiual = TestClass_AccountCreator.createPersonAccount();
        Campaign camp = new Campaign();
        camp.Name = 'MyCampaign';
        camp.Market_ID__c = 'KR';
        insert camp;

        Contact con = [SELECT Id FROM Contact WHERE AccountId = :secondaryIndvidiual.Id];

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = camp.Id;
        cm.ContactId = con.Id;
        insert cm;

        Test.startTest();
        String output = CustomerRegistrationFlowController.setCampaignMemberAsResponded(cm.Id);
        Test.stopTest();

        Assert.isNotNull(output);

    }
}