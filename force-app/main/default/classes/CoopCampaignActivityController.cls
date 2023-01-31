public class CoopCampaignActivityController {
	@AuraEnabled
    public static List<Id> getActivityFiles(Id campaignActivityId) {
        List<Id> fileIds = new List<Id>();
        System.debug('Getting document links for ' + campaignActivityId);
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntity.Type = 'CooP_Campaign_Activity__c' AND LinkedEntityId = :campaignActivityId]){
            fileIds.add(cdl.ContentDocumentId);
        }
        System.debug('Got list of files for ' + campaignActivityId + ': ' + fileIds);
        return fileIds;
    }
}