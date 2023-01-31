public class CoopCampaignController {
	@AuraEnabled
    public static List<CooP_Campaign_Activity__c> getCampaignActivities(Id campaignId) {
        List<CooP_Campaign_Activity__c> campaignActivities = [SELECT Id, Name, Status__c,Has_Attachment__c FROM CooP_Campaign_Activity__c WHERE Campaign__r.id = :campaignId];
    	return campaignActivities;
    }

}