public class CampaignTriggerHandler {
    Static string co_op_campaign_recordTypeName = 'Co_Op';
    Static string co_op_retailer_recordTypeName = 'Co_Op_Retailer';  
    Static string co_op_regional_recordTypeName = 'Regional_Plan';
    public static boolean isTriggerNotActive=false;
    //Id rt_coop = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
    
    public void BeforeInsert(List<Campaign> campaigns) 
    {
        LocalCampaignBudgetCalculationsLogic LCBCL = new LocalCampaignBudgetCalculationsLogic();
        LCBCL.beforeInsertLogic(   campaigns);
        CampaignEstimatedRevenueSetter_Factory campaignEstimatedRevenueSetterFactory = new CampaignEstimatedRevenueSetter_Factory();
        CampaignEstimatedRevenueSetter campaignEstimatedRevenueSetter = campaignEstimatedRevenueSetterFactory.Create();
        
        campaignEstimatedRevenueSetter.SetEstimatedRevenue(campaigns);
        
        ValidatePlannedSpend(null, Trigger.new);
    }
    
    public void AfterInsert(List<Campaign> campaigns) {
        DetermineBudgetWarning(campaigns, null);
        //Given retailer users access to the new records
        RecordSharer sharer = new RecordSharer();       
        sharer.Share_Campaign(campaigns);
        //run auto share to retailer for co-op campaign
         coop_CampaignSharingLogic ccsl = new coop_CampaignSharingLogic();
        ccsl.ShareCoopCampaignsWithRetailer(campaigns, null);
        updateCampActivityOnStatusChange(campaigns,null);
    }
    
    public void AfterUpdate(List<SObject> campaignTrigger, Map<ID, Campaign> oldMap, Map<ID, Campaign> newMap){
          //System.debug('Entered After Update');
        List<Campaign> campaigns = campaignTrigger;
        //record type ids
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(co_op_retailer_recordTypeName).getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(co_op_campaign_recordTypeName).getRecordTypeId();
        Id coopRegionalRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(co_op_regional_recordTypeName).getRecordTypeId();

        List<Campaign> reimbursementCampaigns = new List<Campaign>();
        List<Campaign> campaignsToShare = new List<Campaign>();
        Set<Id> regionalCampaignIds = new Set<Id>();
        
      //  List<Campaign> NonCoopcampaigns = New List<Campaign>();
      //   for(Campaign campaign : campaigns)
       //  { 
      //  if(campaign.RecordTypeId != coopRecordTypeId && campaign.RecordTypeId != retailerRecordTypeId  && campaign.RecordTypeId != coopRegionalRecordTypeId ){
      //      NonCoopcampaigns.add(campaign);
       // }
      //  }
       // if(!NonCoopcampaigns.isEmpty()){
              coopStatsRollUpLogic rollup = new coopStatsRollUpLogic();
            // rollup.updateCooPParentsStatFields(NonCoopcampaigns);  
             rollup.updateCooPParentsStatFields(campaigns);    
       // }
      
        for(Campaign campaign : campaigns)
        { 
         
         
            if(campaign.RecordTypeId == retailerRecordTypeId){    
            
                if(oldMap.get(campaign.Id).Retailer_Quarter_Budget__c != newMap.get(campaign.Id).Retailer_Quarter_Budget__c){
                    if(campaign.ParentId != null){
                        regionalCampaignIds.add(campaign.ParentId);
                    }
                }
                if(oldMap.get(campaign.id).Retailer__c != campaign.Retailer__c){
                    campaignsToShare.add(campaign);
                }
            }else{
                if(campaign.RecordTypeId == coopRecordTypeId){
                    if(oldMap.get(campaign.id).ParentId != campaign.ParentId){
                        campaignsToShare.add(campaign);
                    }
                    if(campaign.Reimbursement__c && !oldMap.get(campaign.id).Reimbursement__c){
                        System.debug('reimbursement Name '+campaign.Name);
                        reimbursementCampaigns.add(campaign);
                    }
                }
            }
        }
        
     

        if(!reimbursementCampaigns.isEmpty()){
            SetCampaignChildrenToReimbursed(reimbursementCampaigns);
        }
        if(!regionalCampaignIds.isEmpty()){
            CalculateRegionalQuarterBudget(regionalCampaignIds);
        }
        
        
        
        DetermineBudgetWarning(campaigns, oldMap);
        coop_CampaignSharingLogic ccsl = new coop_CampaignSharingLogic();
        ccsl.ShareCoopCampaignsWithRetailer(campaignsToShare, oldMap);
        updateCampActivityOnStatusChange(campaigns,oldMap);
    }
    
    private void SetCampaignChildrenToReimbursed(List<Campaign> coopCampaigns) {
         //System.debug('SetCampaignChildrenToReimbursed');
        Set<Id> campaignIds = new Set<Id>();
        Set<Id> campaignActivityIds = new Set<Id>();
        //loop through campaigns CampaignActivity records
        for(Campaign coop : coopCampaigns){
            campaignIds.add(coop.Id);
        }
        List<CooP_Campaign_Activity__c> campaignActivities = [SELECT Id, Status__c FROM CooP_Campaign_Activity__c WHERE Campaign__c IN :campaignIds];
           //System.debug('got coop campaign activty '+campaignActivities.Size());
        for(Coop_Campaign_Activity__c coopActivity : campaignActivities){
            coopActivity.Status__c = 'Reimbursed';
            campaignActivityIds.add(coopActivity.Id);
        }
        
        List<Campaign_Activity_Evidence__c> campaignEvidences = [SELECT Id, Status__c FROM Campaign_Activity_Evidence__c WHERE Campaign_Activity__c IN :campaignActivityIds];
          //System.debug('got coop campaign activty evidence '+ campaignEvidences.Size());
            
        for(Campaign_Activity_Evidence__c coopEvidence : campaignEvidences){
            coopEvidence.Status__c = 'Reimbursed';
        }
        if(!campaignActivities.isEmpty()){
           // Approval.lock(campaignActivities, True); //unlock the records
            update campaignActivities;
           // Approval.lock(campaignActivities, false); //lock the records
        }
        if(!campaignEvidences.isEmpty()){
         //   Approval.lock(campaignEvidences, True); //unlock the records
            update campaignEvidences;
          //  Approval.lock(campaignEvidences, false); //lock the records
        }        
    }
    
    private void CalculateRegionalQuarterBudget(Set<Id> regionalIds) {
        Map<Id, Campaign> regionalMap = new Map<Id, Campaign>();
        if(!regionalIds.isEmpty()){
            for(Campaign c : [SELECT Id, Regional_Quarter_Budget__c FROM Campaign WHERE Id IN :regionalIds]){
                c.Regional_Quarter_Budget__c = 0;
                regionalMap.put(c.Id, c);
            }
            if(!regionalMap.isEmpty()){
                for(Campaign c : [SELECT Id, ParentId, Retailer_Quarter_Budget__c FROM Campaign WHERE ParentId IN :regionalMap.keySet() AND Retailer_Quarter_Budget__c != null]){
                    regionalMap.get(c.ParentId).Regional_Quarter_Budget__c += c.Retailer_Quarter_Budget__c;
                }
                update regionalMap.values();
            }
        }
    }
    
    public void ValidatePlannedSpend(Map<Id, Campaign> oldMap, List<Campaign> newList) {
        //for all Retailer Campaigns, determine whether Planned_Spend_To_Date_per_retailer__c is changed
        List<Campaign> changedCampaigns = new List<Campaign>();
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        for(Campaign c : newList){
            if(c.RecordTypeId == retailerRecordTypeId && c.Planned_Spend_To_Date_per_retailer__c != null){
                if(oldMap == null || oldMap.get(c.Id) == null){
                    changedCampaigns.add(c);
                }
                else if(c.Planned_Spend_To_Date_per_retailer__c != oldMap.get(c.Id).Planned_Spend_To_Date_per_retailer__c){
                    changedCampaigns.add(c);
                }
            }
        }
        for(Campaign c : changedCampaigns){
            if(c.Planned_Spend_To_Date_per_retailer__c > c.Retailer_Quarter_Budget__c){
                c.Planned_Spend_To_Date_per_retailer__c.addError('Your planned spend exceeds the Retailer Quarterly Budget');
            }
        }
    }
    
    private void DetermineBudgetWarning(List<Campaign> newList, Map<Id, Campaign> oldMap) {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        List<Campaign> retailerCampaigns = new List<Campaign>();
        Set<Id> childCoopParentIds = new Set<Id>();
        Map<Id, Campaign> parentCoopCampaigns = new Map<Id, Campaign>();
        for(Campaign c : newList){
            if(c.RecordTypeId == retailerRecordTypeId){ //if the Retailer_Quarter_Budget__c has changed, we need to determine the difference between Retailer_Quarter_Budget__c and childs' BudgetedCost
                if(oldMap != null && oldMap.containsKey(c.Id) && oldMap.get(c.Id).Retailer_Quarter_Budget__c != c.Retailer_Quarter_Budget__c){
                    retailerCampaigns.add(c);
                }
            }
            else if(c.RecordTypeId == coopRecordTypeId){ //if this is a new Campaign we need to sum the BudgetedCost for all of the parent's children; if the BudgetedCost has changed, we need to determine the difference between BudgetedCost and childs' Plannedspend
                if(oldMap == null || !oldMap.containsKey(c.Id)){
                    if(c.ParentId != null){
                        childCoopParentIds.add(c.ParentId);
                    }
                }
                else if(oldMap.get(c.Id).BudgetedCost != c.BudgetedCost){
                    parentCoopCampaigns.put(c.Id, c);
                }
            }
        }
        if(!parentCoopCampaigns.isEmpty()){
            System.debug('Summing Campaign Activities for Campaigns: ' + parentCoopCampaigns);
            DetermineBudgetWarningForCoopCampaigns(parentCoopCampaigns);
        }
        //if(!retailerCampaigns.isEmpty()){
        //    DetermineBudgetWarningForRetailerCampaigns(retailerCampaigns);
        //}
        Map<Id, Campaign> allParentCampaigns = new Map<Id, Campaign>();
        if(!retailerCampaigns.isEmpty()){
            for(Campaign c : retailerCampaigns){
                allParentCampaigns.put(c.Id, c);
            }
        }
        if(!childCoopParentIds.isEmpty()){
            for(Campaign c : [SELECT Id, Retailer_Quarter_Budget__c FROM Campaign WHERE Id IN :childCoopParentIds]){
                allParentCampaigns.put(c.Id, c);
            }
        }
        if(!allParentCampaigns.isEmpty()){
            System.debug('Summing child campaigns for campaigns: ' + allParentCampaigns);
            DetermineBudgetWarningForRetailerCampaigns(allParentCampaigns);
        }
    }
    
    private void DetermineBudgetWarningForCoopCampaigns(Map<Id, Campaign> coopCampaigns){
        //for each Campaign, determine the BudgetedCost and then sum the total PlannedSpend for all child Campaign_Activity__c records
        Map<Id, Double> totalSpend = new Map<Id, Double>();
        for(CooP_Campaign_Activity__c ca : [SELECT Campaign__c, PlannedspendforActivity__c FROM CooP_Campaign_Activity__c WHERE Campaign__c IN :coopCampaigns.keySet() AND PlannedspendforActivity__c != null]){
            Double currentSpend = 0;
            if(totalSpend.containsKey(ca.Campaign__c)){
                currentSpend = totalSpend.get(ca.Campaign__c);
            }
            currentSpend += ca.PlannedspendforActivity__c;
            totalSpend.put(ca.Campaign__c, currentSpend);
        }
        System.debug('Total PlannedspendforActivity: ' + totalSpend);
        List<Campaign> campaignsToUpdate = new List<Campaign>();
        for(Id campaignId : coopCampaigns.keySet()){
            System.debug('Budget for campaign: ' + coopCampaigns.get(campaignId).BudgetedCost);
            if(totalSpend.containsKey(campaignId)){
                boolean showWarning = coopCampaigns.get(campaignId).BudgetedCost < totalSpend.get(campaignId);
                campaignsToUpdate.add(new Campaign(Id=campaignId, Show_Coop_Budget_Warning__c=showWarning));
                System.debug('Show warning: ' + showWarning);
            }
        }
        update campaignsToUpdate;
    }
    
    private void DetermineBudgetWarningForRetailerCampaigns(Map<Id, Campaign> retailerCampaigns){
        //for each Campaign, determine the Retailer_Quarter_Spend__c and then sum the total BudgetedCost for all child Campaign records
        Map<Id, Double> totalSpend = new Map<Id, Double>();
        for(Campaign c : [SELECT ParentId, BudgetedCost FROM Campaign WHERE ParentId IN :retailerCampaigns.keySet() AND BudgetedCost != null]){
            Double currentSpend = 0;
            if(totalSpend.containsKey(c.ParentId)){
                currentSpend = totalSpend.get(c.ParentId);
            }
            currentSpend += c.BudgetedCost;
            totalSpend.put(c.ParentId, currentSpend);
        }
        List<Campaign> campaignsToUpdate = new List<Campaign>();
        for(Id campaignId : retailerCampaigns.keySet()){
            if(totalSpend.containsKey(campaignId)){
                boolean showWarning = retailerCampaigns.get(campaignId).Retailer_Quarter_Budget__c < totalSpend.get(campaignId);
                campaignsToUpdate.add(new Campaign(Id=campaignId, Show_Coop_Budget_Warning__c=showWarning));
            }
        }
        update campaignsToUpdate;
    }
    

    
    



  public void BeforeUpdate(Map<Id,Campaign> oldCampaigns, List<Campaign> newCampaigns)
    {  
       LocalCampaignBudgetCalculationsLogic LCBCL = new LocalCampaignBudgetCalculationsLogic();
        LCBCL.beforeUpdateLogic( oldCampaigns,  newCampaigns);
        
    }



    public void updateCampActivityOnStatusChange(list<Campaign> newRec, map<Id,Campaign> OldMap){
        if(isTriggerNotActive)
            return;
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        map<id,String> campignIdToStatusMap= new map<Id,string>();
        for(Campaign singleRec:newRec){
            if((OldMap!=null && singleRec.Status != OldMap.get(singleRec.id).Status) 
              && (singleRec.Status=='Plan Submitted' || singleRec.Status=='Plan Approved' || singleRec.Status=='Campaign Needs Modification')
              && retailerRecordTypeId==singleRec.RecordTypeId)
            {
                campignIdToStatusMap.put(singleRec.Id,singleRec.status);
            }
        }
        
        list<CooP_Campaign_Activity__c> campaignActivityList = [select id,
                                                                	   Status__c,
                                                                	   Campaign__c 
                                                                from CooP_Campaign_Activity__c 
                                                                where Status__c Not IN ('Activity Canceled', 'Activity Rejected','Cancellation Submitted') 
                                                                And Campaign__c IN :campignIdToStatusMap.keySet()
                                                                AND Is_Locked__c=false];
        
        for(CooP_Campaign_Activity__c camActivity: campaignActivityList)
        {
           if(campignIdToStatusMap.get(camActivity.Campaign__c)=='Plan Submitted')
              camActivity.Status__c='Ready for Approval'; 
            else if(campignIdToStatusMap.get(camActivity.Campaign__c)=='Plan Approved' && camActivity.Status__c!='Activity Created')
              camActivity.Status__c='Activity Approved';
            else if(campignIdToStatusMap.get(camActivity.Campaign__c)=='Campaign Needs Modification' && camActivity.Status__c!='Activity Created')
              camActivity.Status__c='Activity Needs Modification';
        }
        
        if(!campaignActivityList.isEmpty())
            update campaignActivityList;
    }
}