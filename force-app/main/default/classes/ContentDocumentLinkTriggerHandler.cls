public class ContentDocumentLinkTriggerHandler {
    
    public static void AttachmentInsert(List<ContentDocumentLink> links){
         
        Set<Id> claimIds=new Set<Id>();
        List<VME_Claims__c> claimsList=new List<VME_Claims__c>();
        List<sObject> sObjectList=new List<sObject>();
        Map<String,String> objectMap = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        Map<Id,Integer> entityAttCountMap = new Map<Id,Integer>();
        string relatedObjectName;
        for(String s:describe.keyset()){
            objectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
        }
        for(ContentDocumentLink cdl : links){
            
            String linkedObjectAPIName = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            if(linkedObjectAPIName=='VME_Claims__c')
                claimIds.add(cdl.LinkedEntityId);
            else if(linkedObjectAPIName=='Creative_Brief__c' || linkedObjectAPIName=='Campaign_Activity_Evidence__c')
            {
                relatedObjectName=linkedObjectAPIName;
                if(!entityAttCountMap.containsKey(cdl.LinkedEntityId))
                    entityAttCountMap.put(cdl.LinkedEntityId,0);
                entityAttCountMap.put(cdl.LinkedEntityId,entityAttCountMap.get(cdl.LinkedEntityId)+1);
            }
        }
        if(claimIds!=null && !claimIds.isEmpty()){
            claimsList=[Select Id,VME_Number_Of_Attachments__c from VME_Claims__c where Id IN :claimIds];
            for(VME_Claims__c clm : claimsList){
                if(clm.VME_Number_Of_Attachments__c!=null){
                    clm.VME_Number_Of_Attachments__c = clm.VME_Number_Of_Attachments__c+1;
                }
            } 
        }
        if(entityAttCountMap!=null && !entityAttCountMap.isEmpty())
        {
            set<Id> Keys=entityAttCountMap.keySet();
            sObjectList= database.query('select Id, Attachment_Count__c from '+relatedObjectName+' where ID IN:Keys');
            for(sObject SinglesObject:sObjectList)
            {
                if(SinglesObject.get('Attachment_Count__c') !=null)
                    SinglesObject.put('Attachment_Count__c', Integer.valueOf(SinglesObject.get('Attachment_Count__c'))+entityAttCountMap.get((string)SinglesObject.get('Id')));
                else
                    SinglesObject.put('Attachment_Count__c', entityAttCountMap.get((string)SinglesObject.get('Id')));
            }
        }
        if(!claimsList.isEmpty())
            update claimsList;
        
        if(!sObjectList.isEmpty())
            update sObjectList;
        
    }
    
    
    public void preDelete(List<ContentDocumentLink> links){
        Map<String,String> objectMap = new Map<String,String>();
        Set<Id> caseIdSet = New Set<Id>();
        Map<Id, Case> caseMap;
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset()){
            objectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
        }
        
        for(ContentDocumentLink cdl : links){
            String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            if(linkedObject=='Case')
                caseIdSet.add(cdl.LinkedEntityId);
        }
        
        if(!caseIdSet.isEmpty())
        {
            caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: caseIdSet]);
        }
        system.debug('caseMap'+caseMap);
        for(ContentDocumentLink cdl : links){
            String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            
            if(linkedObject=='Case')
            {
                system.debug('Here');
                
                Case c = caseMap.get(cdl.LinkedEntityId);
                if(c != null && (c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Solved')){
                    if(!FeatureManagement.checkPermission('Modify_closed_case_related_items')){
                        cdl.addError(Label.Error_Edit_Closed_Cases);
                    }
                }
            }
            if(Approval.isLocked(cdl.LinkedEntityId) && (linkedObject=='Creative_Brief__c' || linkedObject=='Creatives__c' || linkedObject=='Campaign_Activity_Evidence__c'))
                cdl.addError('Cannot modify attachments on locked records.');
        }
    }  
    
    
    
    public void PostDelete(List<ContentDocumentLink> links){
        Set<Id> sObjectId= new Set<Id>();
        String linkedObjectAPIName;
        List<sObject> sObjectList=new List<sObject>();
        Map<String,String> objectMap = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset()){
            objectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
        }
        
        for(ContentDocumentLink cdl : links){
            linkedObjectAPIName = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            if(linkedObjectAPIName=='Creative_Brief__c' || linkedObjectAPIName=='Campaign_Activity_Evidence__c')
            {
                sObjectId.add(cdl.LinkedEntityId);
            }
        }
        
        if(sObjectId!=null && !sObjectId.isEmpty())
        {
            sObjectList= database.query('select Id, Attachment_Count__c from '+linkedObjectAPIName+' where ID IN:sObjectId');
            for(sObject singlesObject:sObjectList)
            {
                SinglesObject.put('Attachment_Count__c', Integer.valueOf(SinglesObject.get('Attachment_Count__c'))-1);
            }
        }
        
        if(!sObjectList.isEmpty())
            update sObjectList;
    }
    
    
    public void SetVisibilityForCommunityUsers(List<ContentDocumentLink> links) {
        Map<String,String> objectMap = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        
        Set<Id> caseIdSet = New Set<Id>();
        Map<Id, Case> caseMap;
        
        for(String s:describe.keyset()){
            objectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
        }
        
        for(ContentDocumentLink cdl : links){
            String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            if(linkedObject=='Case')
                caseIdSet.add(cdl.LinkedEntityId);
        }
        
        if(!caseIdSet.isEmpty())
        {
            caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: caseIdSet]);
        }
        
        for(ContentDocumentLink cdl : links){
            String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            
            if(linkedObject=='Case')
            {
                Case c = caseMap.get(cdl.LinkedEntityId);
                if(c != null && (c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Solved')){
                    if(!FeatureManagement.checkPermission('Modify_closed_case_related_items')){
                        cdl.addError(Label.Error_Edit_Closed_Cases);
                    }
                }
            }
            
            if(Approval.isLocked(cdl.LinkedEntityId) && (linkedObject=='Creative_Brief__c' || linkedObject=='Creatives__c' || linkedObject=='Campaign_Activity_Evidence__c'))
                cdl.addError('Cannot insert/update attachments on locked records.');
            if(cdl.Visibility != 'AllUsers'){
                if(cdl.LinkedEntityId != null){
                    if(linkedObject == 'coop_campaign_activity__c' || linkedObject == 'campaign_activity_evidence__c' || linkedObject == 'campaign' || linkedObject == 'Creative_Brief__c'){
                        cdl.Visibility = 'AllUsers';
                    }
                }
            }
        }
    }
    
}





/*   for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntity.Type = 'Campaign_Activity_Evidence__c' AND LinkedEntityId = :campaignActivityId]){
fileIds.add(cdl.ContentDocumentId); */