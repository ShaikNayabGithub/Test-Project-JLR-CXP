global class COOP_CampActivityCleanupBatch implements Database.Batchable<sObject>{
    List<String> ListOfCountryToInclude=system.label.COOP_Contry_To_Include_in_Carryfwd.split(';');
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'select id, Status from campaign where '+
            'StartDate =LAST_FISCAL_QUARTER AND recordtype.Name=\'Co Op Retailer\' AND '+
            'endDate=LAST_FISCAL_QUARTER AND Market__c IN:ListOfCountryToInclude order by Retailer__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<campaign> campList) {
        Set<Id> campIdSet= New Set<Id>();
        List<Approval.ProcessWorkitemRequest> allRequests = new List<Approval.ProcessWorkitemRequest>();
        Map<Id,CooP_Campaign_Activity__c> campActivyMap;
        List<Campaign> campaignLstForUpdate= New List<Campaign>();
        Set<Id> recordsInApproval= New Set<Id>();
        
        Set<Id> CampActvyInApvlSet= New Set<Id>();
        for(campaign camp:campList)
        {
          campIdSet.add(camp.id);
            if(camp.Status !='Plan Approved' && camp.Status !='Plan Rejected')
            {
                camp.Status='Plan Rejected';
                campaignLstForUpdate.add(camp);
            }
        }
        
        campActivyMap= New Map<Id,CooP_Campaign_Activity__c>([select id, Status__c from CooP_Campaign_Activity__c where Campaign__c IN:campIdSet AND Status__c NOT IN ('Activity Approved','Activity Rejected','Activity Canceled')]);
        
        for(CooP_Campaign_Activity__c campActvy:campActivyMap.Values())
        {
            campActvy.Status__c='Activity Rejected';
        }
        
        for(ProcessInstanceWorkitem piwi : [SELECT  Id, 
                                                ProcessInstance.TargetObjectId
                                                FROM ProcessInstanceWorkitem 
                                                WHERE 
                                                ProcessInstance.Status = 'Pending' AND 
                                                (ProcessInstance.TargetObjectId IN : campIdSet OR
                                                 ProcessInstance.TargetObjectId IN :campActivyMap.keySet())])
            {
                if(!recordsInApproval.contains(piwi.ProcessInstance.TargetObjectId))
                {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Auto recalled from approval due to end of quarter.');
                req.setAction('Removed');
                req.setWorkitemId(piwi.id);
                allRequests.add(req); 
                recordsInApproval.add(piwi.ProcessInstance.TargetObjectId);
                }
            }
        
        	if(!allRequests.isEmpty())
            {
                Approval.ProcessResult[] processResults = null;
                processResults = Approval.process(allRequests, true);  
            }
        
          if(!campaignLstForUpdate.isEmpty())
              Update campaignLstForUpdate;
        
          if(!campActivyMap.isEmpty())
              Update campActivyMap.values();
        
        if(!campaignLstForUpdate.isEmpty())
              Approval.Lock(campaignLstForUpdate,false);        
        
          if(!campActivyMap.isEmpty())
              Approval.Lock(campActivyMap.values(),false);        

    }
    
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}