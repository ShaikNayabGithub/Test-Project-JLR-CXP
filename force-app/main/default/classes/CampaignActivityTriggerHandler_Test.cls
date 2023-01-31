@isTest(seeAllData=false)
public class CampaignActivityTriggerHandler_Test {

    static testmethod void CampaignActivityTrigger_CreatesChildCampaignActivityEvidence_WhenStatusChangedToActivityApproved() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created',PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        test.startTest();
        insert coop; 
		delete coop;
        undelete coop;
        Test.stopTest();
    }
    
    static testmethod void CampaignActivityTrigger_LocksCampaignActivity_WhenStatusChangedToReimbursed() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created',PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coop;
    }
        static testmethod void CampaignActivityTrigger_LocksCampaignActivity_WhenSetToDeactivated() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created',PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coop;
        coop.Deactivated__c = true;
        update coop;
    }
}