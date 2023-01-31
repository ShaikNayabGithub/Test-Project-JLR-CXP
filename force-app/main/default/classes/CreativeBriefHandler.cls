public class CreativeBriefHandler {
    
    public static void PreInsert(List<Creative_Brief__C> newRecords)
    {
        Set<Id> camActivityIdSet= New Set<Id>();
        Map<Id,String> camActvyCountryMap= New Map<Id,String>();
        
        for(Creative_Brief__C objCB:newRecords)
        {
            if(objCB.Campaign_Activity__c!=null)
                camActivityIdSet.add(objCB.Campaign_Activity__c);
            
            if(objCB.Status__c=='CB Created')
                objCB.Status__c='CB Assigned';
        }
        
        if(!camActivityIdSet.isEmpty())
            for(CooP_Campaign_Activity__c objCampActvy:[Select id,
                                                        Campaign__r.Market_ID__c 
                                                        from CooP_Campaign_Activity__c 
                                                        where ID IN:camActivityIdSet 
                                                        AND Campaign__c !=null])
        {
            camActvyCountryMap.put(objCampActvy.Id, objCampActvy.Campaign__r.Market_ID__c); 
        }
        
        if(!camActvyCountryMap.isEmpty())
        {
            for(Creative_Brief__C objCB:newRecords)
            {
                if(camActvyCountryMap.containsKey(objCB.Campaign_Activity__c))
                    objCB.Country__c=camActvyCountryMap.get(objCB.Campaign_Activity__c);
            }
        }
        
    }
    
    public static void PostUpdate(List<Creative_Brief__C> newRecords, Map<Id,Creative_Brief__C> OldMap)
    {
        Set<Id> approvedCBIdSet= new set<Id>();
        Map<Id,ContentDocumentLink> contentDocLinkMap= New Map<Id,ContentDocumentLink>();
        Map<Id,Id> creativeBfActivityIdMap= New Map<Id,Id>();
        Map<Id,Id> creativeBfcreativeIdMap= New Map<Id,Id>();
        list<Creatives__c> creativeLstForInsert= New List<Creatives__c>();
        List<ContentDocumentLink> contentDocLinkLstForInsert= New List<ContentDocumentLink>();
        List<Activity_Creative__c> activityCreativeLst= New List<Activity_Creative__c>();
        ContentDocumentLink objApprovedCD;
        
        for(Creative_Brief__C objCB:newRecords)
        {
            if(OldMap !=null 
               && objCB.Status__c=='CB Approved' && objCB.Status__c !=OldMap.get(objCB.Id).Status__c )
            {
                approvedCBIdSet.add(objCB.Id);
                creativeBfActivityIdMap.put(objCB.Id,objCB.Campaign_Activity__c);
                creativeLstForInsert.add(new Creatives__c(Name=objCB.Brand__c+'-'+objCB.Type__c+'-'+objCB.Format__c , Creative_Brief__c=objCB.Id));
            }
        }
        
        if(!approvedCBIdSet.isEmpty())
        {
            for(ContentDocumentLink objConDocLink:[select Id,
                                                   LinkedEntityId,
                                                   ContentDocumentId,
                                                   ShareType,
                                                   Visibility
                                                   from
                                                   ContentDocumentLink 
                                                   where LinkedEntityId IN:approvedCBIdSet
                                                   ORDER BY SystemModstamp DESC 
                                                  ])
            {
                if(!contentDocLinkMap.containsKey(objConDocLink.LinkedEntityId))
                    contentDocLinkMap.put(objConDocLink.LinkedEntityId,objConDocLink);
            }
            
            if(!creativeLstForInsert.isEmpty())
            {
                Insert creativeLstForInsert;
            }
            
            for(Creatives__c objCreative:creativeLstForInsert)
            {
                activityCreativeLst.add(new Activity_Creative__c(Creative__c=objCreative.Id,Campaign_Activity__c=creativeBfActivityIdMap.get(objCreative.Creative_Brief__c), Status__c='Approved'));
                
                creativeBfcreativeIdMap.put(objCreative.Creative_Brief__c,objCreative.Id);
                if(contentDocLinkMap.containsKey(objCreative.Creative_Brief__c))
                {
                    objApprovedCD=contentDocLinkMap.get(objCreative.Creative_Brief__c);
                    ContentDocumentLink objContentDocLink= New ContentDocumentLink();
                    objContentDocLink.ContentDocumentId=objApprovedCD.ContentDocumentId;
                    objContentDocLink.ShareType=objApprovedCD.ShareType;
                    objContentDocLink.LinkedEntityId=objCreative.Id;
                    objContentDocLink.Visibility='AllUsers';
                    contentDocLinkLstForInsert.add(objContentDocLink);
                }
            }
            
            if(!activityCreativeLst.isEmpty()){
                insert activityCreativeLst;
                Approval.Lock(activityCreativeLst,false);
            }
            
            if(!contentDocLinkLstForInsert.isEmpty())
                Insert contentDocLinkLstForInsert;
            
            if(!creativeLstForInsert.isEmpty())
                Approval.Lock(creativeLstForInsert,false);
        }
    }
}