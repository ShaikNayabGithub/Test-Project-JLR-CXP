/**
* @author Suhan Jain -NTT Data
* @date 22 Apr 2020
*
*
* @description Trigger Handler on ContentVersion 
*/

public class ContentVersionTriggerHandler {
    
    public static void preInsert(list<ContentVersion> newRecords)
    {
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Map<Id,Id> contentDocEntityIdMap= New Map<Id,Id>();
        
        Map<String,String> objectMap = new Map<String,String>();
        Set<Id> caseIdSet = New Set<Id>();
        Map<Id, Case> caseMap= new Map<Id, Case>();
        Map<Id,Id> conDocCaseIdMap = New Map<Id,Id>();
        
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset()){
            objectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
        }
        
        for(ContentVersion cv:newRecords)
        {
            if(cv.ContentDocumentId != null)
            {
                contentDocumentIdSet.add(cv.ContentDocumentId);
            }
        }
        if(!contentDocumentIdSet.isEmpty())
        {
            for(ContentDocumentLink cdl:[select ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet])
            {
                String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
                if(Approval.IsLocked(cdl.LinkedEntityId) && (linkedObject=='Creative_Brief__c' || linkedObject=='Creatives__c' || linkedObject=='Campaign_Activity_Evidence__c'))
                    contentDocEntityIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                
                if(linkedObject=='Case')
                {
                	caseIdSet.add(cdl.LinkedEntityId);
                    conDocCaseIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                }
            }
            
            if(!caseIdSet.isEmpty())
            {
                caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: caseIdSet AND (Status='Closed' OR Status='Cancelled' OR Status='Solved')]);
            }
            
            if(!contentDocEntityIdMap.isEmpty() || !caseMap.isEmpty())
            {
                for(ContentVersion cv:newRecords)
                {
                    if(cv.ContentDocumentId != null && contentDocEntityIdMap.containsKey(cv.ContentDocumentId))
                    {
                        cv.addError('Cannot upload new version. This attachment is linked to locked records.');
                    }
                    
                    if(!caseMap.isEmpty() && cv.ContentDocumentId !=null 
                       && caseMap.containsKey(conDocCaseIdMap.get(cv.ContentDocumentId))
                       && !FeatureManagement.checkPermission('Modify_closed_case_related_items'))
                        cv.addError(Label.Error_Edit_Closed_Cases);
                }
            }
        }
    }
}