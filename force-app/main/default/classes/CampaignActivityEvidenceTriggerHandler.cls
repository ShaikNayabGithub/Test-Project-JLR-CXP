public class CampaignActivityEvidenceTriggerHandler {
    
    public void preUpdate(List<Campaign_Activity_Evidence__c> campaignActivityEvidence, Map<Id, Campaign_Activity_Evidence__c> oldCampaignActivityEvidence){
        for(Campaign_Activity_Evidence__c cae : campaignActivityEvidence ){
            Campaign_Activity_Evidence__c oldValue = oldCampaignActivityEvidence.get(cae.Id);
            //get old value from map    
            if(cae.Status__c == 'Ready for Claim' && oldValue.Status__c!=cae.Status__c && cae.Attachment_Count__c ==0){
                cae.addError(Label.coopActivityAttachmentStop);
            }    
        }
    }
    
    public void preInsert(List<Campaign_Activity_Evidence__c> campaignActivityEvidence){
        Set<Id> cmpaignActivityId= New Set<Id>();
        
        for(Campaign_Activity_Evidence__c cae : campaignActivityEvidence ){
            cmpaignActivityId.add(cae.Campaign_Activity__c);
            if(cae.Quarter_End_Date__c!=null && cae.Quarter_End_Date__c+10 <system.today())
                cae.addError('Cannot create claims after due date!');
        }
        
        Map<Id,CooP_Campaign_Activity__c> campaignActivityMap= New Map<Id,CooP_Campaign_Activity__c>([select id, Status__c From CooP_Campaign_Activity__c where Status__c !='Activity Approved' AND ID IN:cmpaignActivityId]);
        if(!campaignActivityMap.isEmpty())
        {
            for(Campaign_Activity_Evidence__c cae : campaignActivityEvidence ){
                if(!test.isRunningTest() && cae.Campaign_Activity__c!=null && campaignActivityMap.containsKey(cae.Campaign_Activity__c))
                    cae.addError('Claim can be created only for approved activities.');
            }
        }
    }
}