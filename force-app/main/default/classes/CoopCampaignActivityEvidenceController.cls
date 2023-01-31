public class CoopCampaignActivityEvidenceController {
@AuraEnabled
    public static List<Id> getActivityFiles(Id campaignActivityId) {
        List<Id> fileIds = new List<Id>();
        System.debug('Getting document links for ' + campaignActivityId);
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntity.Type = 'Campaign_Activity_Evidence__c' AND LinkedEntityId = :campaignActivityId]){
            fileIds.add(cdl.ContentDocumentId);
        }
        System.debug('Got list of files for ' + campaignActivityId + ': ' + fileIds);
        return fileIds;
    }
}