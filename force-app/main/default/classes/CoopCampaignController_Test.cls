@isTest
public class CoopCampaignController_Test {

    public static testmethod void Controller_ReturnsAllCampaignActivities_ForGivenCampaign() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop1 = new CooP_Campaign_Activity__c(Name = 'Test Coop 1', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created');
        CooP_Campaign_Activity__c coop2 = new CooP_Campaign_Activity__c(Name = 'Test Coop 2', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created');
        CooP_Campaign_Activity__c coop3 = new CooP_Campaign_Activity__c(Name = 'Test Coop 3', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created');
        List<CooP_Campaign_Activity__c> coops = new List<CooP_Campaign_Activity__c>();
        coops.add(coop1);
        coops.add(coop2);
        coops.add(coop3);
        insert coops;
        List<CooP_Campaign_Activity__c> campaignActivities = CoopCampaignController.getCampaignActivities(coopCampaign.Id);
        System.assertEquals(3, campaignActivities.size());
    }

}