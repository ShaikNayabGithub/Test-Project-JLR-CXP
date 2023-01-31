public class CoopCampaignEvidenceController {
	@AuraEnabled
    public static List<Campaign_Activity_Evidence__c> getCampaignActivities(Id campaignId) {
        List<Campaign_Activity_Evidence__c> campaignActivities = [SELECT Id, Name, Status__c,Has_Attachment__c, Claim_Value__c, Evidence_Type__c   FROM Campaign_Activity_Evidence__c WHERE Campaign_Activity__r.id = :campaignId];
    	return campaignActivities;
    }
}