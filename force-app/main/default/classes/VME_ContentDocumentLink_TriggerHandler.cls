/*
Name : VME_ContentDocumentLink_Trigger.apxc// Content Document Trigger

Author: Suhan Jain - NTT Data

Purpose: VME Content Document Trigger for  uploading attachment and delete on Creative Brief 

Created Date : 08/05/2019
*/

public class VME_ContentDocumentLink_TriggerHandler 
{
    
    public static void preUpdate(Map<Id,ContentDocument> NewMap, Map<Id,ContentDocument> oldMap)
    {
        Map<String,String> objectMap = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset()){
            objectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
        }
        
        
        Set<Id> caseIdSet = New Set<Id>();
        Map<Id, Case> caseMap;
        
        List<ContentDocumentLink> contentDocLinkLst=[select ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:NewMap.keySet()];
        for(ContentDocumentLink cdl:contentDocLinkLst)
        {
        	String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            if(linkedObject=='Case')
                caseIdSet.add(cdl.LinkedEntityId);
        }
        
        if(!caseIdSet.isEmpty())
        {
            caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: caseIdSet AND (Status='Closed' OR Status='Cancelled' OR Status='Solved')]);
        }
        
        Set<Id> contentDocumentIdSet = new Set<Id>();
        ContentDocument newRecord;
        ContentDocument OldRecord;
        for(ContentDocumentLink cdl:contentDocLinkLst)
        {
            newRecord=NewMap.get(cdl.ContentDocumentId);
            OldRecord=OldMap.get(cdl.ContentDocumentId);
            String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            if( (newRecord.Title !=OldRecord.Title || newRecord.Description !=OldRecord.Description) 
               && Approval.IsLocked(cdl.LinkedEntityId) 
               && (linkedObject=='Creative_Brief__c' || linkedObject=='Creatives__c' || linkedObject=='campaign_activity_evidence__c')
               && !contentDocumentIdSet.contains(cdl.ContentDocumentId))
            {
                newRecord.addError('Cannot update details. This document is linked to locked records.');  
                contentDocumentIdSet.add(cdl.ContentDocumentId);
            }
            
            if(linkedObject=='Case' && !contentDocumentIdSet.contains(cdl.ContentDocumentId))
            {
                Case c = caseMap.get(cdl.LinkedEntityId);
                if(c != null && (c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Solved')){
                    if(!FeatureManagement.checkPermission('Modify_closed_case_related_items')){
                        newRecord.addError(Label.Error_Edit_Closed_Cases);
                        contentDocumentIdSet.add(cdl.ContentDocumentId);
                    }
                }
            }
        }      
    }
    
    public static void preDelete(Map<Id,ContentDocument> oldMap)
    {
        
        Set<Id> claimIds=new Set<Id>();
        Set<Id> sObjectId= new Set<Id>();
        string relatedObjectName;
        List<VME_Claims__c> claimsList=new List<VME_Claims__c>();
        List<sObject> sObjectList=new List<sObject>();
        Set<Id> contentDocIdSet= New Set<Id>();
        
        Set<Id> caseIdSet = New Set<Id>();
        Map<Id, Case> caseMap;
        
        Map<String,String> objectMap = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset()){
            objectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
        }
        List<ContentDocumentLink> contentDocLinkLst=[select ContentDocumentId,
                                     LinkedEntityId 
                                     FROM ContentDocumentLink 
                                     WHERE ContentDocumentId IN:oldMap.keySet()];
        for(ContentDocumentLink cdl:contentDocLinkLst)
        {
            String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            if(linkedObject=='Case')
                caseIdSet.add(cdl.LinkedEntityId);
        }
        
        if(!caseIdSet.isEmpty())
        {
            caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: caseIdSet AND (Status='Closed' OR Status='Cancelled' OR Status='Solved')]);
        }
        
        for(ContentDocumentLink cdl:contentDocLinkLst)
            
        {
            String linkedObject = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            
            if(linkedObject=='Case' && !contentDocIdSet.contains(cdl.ContentDocumentId))
            {
                Case c = caseMap.get(cdl.LinkedEntityId);
                if(c != null && (c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Solved')){
                    if(!FeatureManagement.checkPermission('Modify_closed_case_related_items')){
                        oldMap.get(cdl.ContentDocumentId).addError(Label.Error_Edit_Closed_Cases);
                        contentDocIdSet.add(cdl.ContentDocumentId);
                    }
                }
            }
            
            
            if(!contentDocIdSet.contains(cdl.LinkedEntityId) 
               && Approval.IsLocked(cdl.LinkedEntityId) 
               && (linkedObject=='Creative_Brief__c' || linkedObject=='Creatives__c' || linkedObject=='campaign_activity_evidence__c'))
            {
                oldMap.get(cdl.ContentDocumentId).addError('Cannot delete. This document is linked to locked records.');
                contentDocIdSet.add(cdl.ContentDocumentId);
            }else
            {
                if(linkedObject=='VME_Claims__c')
                    claimIds.add(cdl.LinkedEntityId);
                else if(linkedObject=='Creative_Brief__c' || linkedObject=='campaign_activity_evidence__c')
                {
                    relatedObjectName=linkedObject;
                    sObjectId.add(cdl.LinkedEntityId);
                }
            }
        }
        
        if(!claimIds.isEmpty()){
            claimsList = [Select Id,VME_Number_Of_Attachments__c from VME_Claims__c where Id IN :claimIds];
            for(VME_Claims__c clm : claimsList){
                if(clm.VME_Number_Of_Attachments__c!=null){
                    clm.VME_Number_Of_Attachments__c=clm.VME_Number_Of_Attachments__c - 1;
                }
            }
        }
        if(sObjectId!=null && !sObjectId.isEmpty())
        {
            sObjectList= database.query('select Id, Attachment_Count__c from '+relatedObjectName+' where ID IN:sObjectId');
            for(sObject singlesObject:sObjectList)
            {
                SinglesObject.put('Attachment_Count__c', Integer.valueOf(SinglesObject.get('Attachment_Count__c'))-1);
            }
        }
        if(!claimsList.isEmpty())
            update claimsList;
        
        if(!sObjectList.isEmpty())
            update sObjectList;
        
    }
    
    
    public static void ContentDcoument_Undelete(Map<Id,ContentDocument> newMap){
        Set<Id> cdlinksIds=new Set<Id>();
        Set<Id> claimIds=new Set<Id>();
        Set<Id> sObjectId= new Set<Id>();
        String relatedObjectName;
        List<VME_Claims__c> claimsList=new List<VME_Claims__c>();
        List<sObject> sObjectList=new List<sObject>();
        Map<String,String> objectMap = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset()){
            objectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
        }
        List<ContentDocumentLink> cdLinksList=new List<ContentDocumentLink>();
        cdLinksList=[Select Id,LinkedEntityId from ContentDocumentLink where ContentDocumentId IN :newMap.KeySet()];
        for(ContentDocumentLink cdl : cdLinksList){
            String linkedObjectAPIName = objectMap.get(String.valueOf(cdl.LinkedEntityId).left(3));
            if(linkedObjectAPIName == 'VME_Claims__c')
                claimIds.add(cdl.LinkedEntityId);
            else if(linkedObjectAPIName=='Creative_Brief__c' || linkedObjectAPIName=='campaign_activity_evidence__c')
            {
                relatedObjectName=linkedObjectAPIName;
                sObjectId.add(cdl.LinkedEntityId);
            }
        }
        if(!claimIds.isEmpty()){
            claimsList = [Select Id,VME_Number_Of_Attachments__c from VME_Claims__c where Id IN :claimIds];
            for(VME_Claims__c clm : claimsList){
                if(clm.VME_Number_Of_Attachments__c!=null){
                    clm.VME_Number_Of_Attachments__c=clm.VME_Number_Of_Attachments__c + 1;
                }
            }
        }
        
        if(sObjectId!=null && !sObjectId.isEmpty())
        {
            sObjectList= database.query('select Id, Attachment_Count__c from '+relatedObjectName+' where ID IN:sObjectId');
            for(sObject singlesObject:sObjectList)
            {
                SinglesObject.put('Attachment_Count__c', (Integer)SinglesObject.get('Attachment_Count__c')+1);
            }
        }
        
        if(!claimsList.isEmpty())
            update claimsList;
        
        if(!sObjectList.isEmpty())
            update sObjectList;
    }
}