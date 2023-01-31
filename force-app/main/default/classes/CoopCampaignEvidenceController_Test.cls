@isTest
public class CoopCampaignEvidenceController_Test {

    public static testmethod void Controller_ReturnsAllCampaignActivityEvidence_ForGivenCampaignActivity() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created');
        insert coop;
        Campaign_Activity_Evidence__c evidence = new Campaign_Activity_Evidence__c(Name = 'Test Evidence', Campaign_Activity__c = coop.Id);
        insert evidence;
        List<Campaign_Activity_Evidence__c> campaignEvidence = CoopCampaignEvidenceController.getCampaignActivities(coop.Id);
        System.assertEquals(1, campaignEvidence.size());
    }

}