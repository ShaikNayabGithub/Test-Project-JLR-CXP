public class CampaignActivityTriggerHandler {
    public static Boolean isExecutedCampaignRoolup = false;
     
    public void preUpdate(List<CooP_Campaign_Activity__c> campaignActivities, Map<Id,CooP_Campaign_Activity__c> oldCampaignActivities){
        user currentUser=[select Id, Market__c from user where Id=:userinfo.getUserId() ];
        set<id> campaignId = new set<id>();
        for(CooP_Campaign_Activity__c ca : campaignActivities ){
            campaignId.add(ca.Campaign__c);
        }
        
        Map<Id,Campaign> campaignsMap = new Map<Id,Campaign>( [Select id,Status,Planned_spend_to_date_per_campaign__c, Cumulative_Eligible_Budget__c from campaign where id in:campaignId ]);
        for(CooP_Campaign_Activity__c ca : campaignActivities ){ 
            CooP_Campaign_Activity__c oldValue = oldCampaignActivities.get(ca.Id);
            campaign objCamp=campaignsMap.get(ca.Campaign__c);

            if(ca.Status__c == 'Ready For Approval' && oldValue.Status__c != ca.Status__c
               && ca.Is_Locked__c && objCamp.Status !='Plan Submitted' && objCamp.Status !='Plan Approved'){
               ca.addError('Submitting single activity is not allowed on this plan.');
            }
            if(ca.Status__c == 'Ready For Approval' && oldValue.Status__c != ca.Status__c && objCamp.Planned_spend_to_date_per_campaign__c > objCamp.Cumulative_Eligible_Budget__c){
                ca.addError('Planned spend on marketing plan is more than eligible budget, Please adjust planned spend on activities.');
            } 
            if( !test.isRunningTest() && currentUser.Market__c=='IN' && oldValue.PlannedspendforActivity__c !=ca.PlannedspendforActivity__c && (ca.PlannedspendforActivity__c==null || ca.PlannedspendforActivity__c < 1) ){
                ca.AddError('Activity Budget or Planned spend should be greater than 0');
            }
            if(ca.Status__c == 'Ready For Approval' || ca.Status__c == 'Ready for Cancellation'){
            	ca.Has_Approval_Process__c=true;
            } 
        }
    }
    
    public void postUpdate(List<CooP_Campaign_Activity__c> campaignActivities, Map<Id,CooP_Campaign_Activity__c> oldCampaignActivities){
        Set<Id> campaignId = new Set<Id>();
        List<Campaign> campaigns = new   List<Campaign>();   
        for(CooP_Campaign_Activity__c ca : campaignActivities ){
       
            CooP_Campaign_Activity__c oldValue = oldCampaignActivities.get(ca.Id);
         
            if(oldValue != null && ((oldValue.Number_of_Leads__c != ca.Number_of_Leads__c )|| (oldValue.Number_of_Opportunities__c != ca.Number_of_Opportunities__c )||(oldValue.Number_of_Won_Opportunities__c != ca.Number_of_Won_Opportunities__c )||(oldValue.CXP_Campaign__c != ca.CXP_Campaign__c ) )){
                if(ca.Campaign__c != null){ 
                campaignId.add(ca.Campaign__c); 
                }
                
            }
                  
        }
		if(!campaignId.isEmpty() && campaignId!= null){                
                coopStatsRollUpLogic rollup = new coopStatsRollUpLogic();
                rollup.updateCooPParentsStatFieldsFromCampaignActivity(campaignId);                           
            }  
        coopStatsRollUpLogic.campaignRollup(campaignActivities,oldCampaignActivities);
    }
    
    public void preInsert(List<CooP_Campaign_Activity__c> campaignActivities){
        user currentUser=[select Id, Market__c from user where Id=:userinfo.getUserId() ];
        Set<Id> campaignIDs = SObjectUtilities.GetFieldValuesId(campaignActivities,'Campaign__c');
        Map<Id,Campaign> campaigns = new Map<Id,Campaign>( [Select id,Reimbursement__c from campaign where id in:campaignIDs  ]);
        for(CooP_Campaign_Activity__c ca : campaignActivities){
            Campaign camp =  campaigns.get(ca.Campaign__c);    
            if(camp != null && camp.Reimbursement__c == true){
                ca.AddError(Label.Co_Op_Prevent_New_Campaign_activities_to_reimbursed_campaigns);
            }
            if( !test.isRunningTest() && currentUser.Market__c=='IN' && (ca.PlannedspendforActivity__c==null || ca.PlannedspendforActivity__c < 1) ){
                ca.AddError('Activity Budget or Planned spend should be greater than 0');
            }
            if(ca.Status__c == 'Ready For Approval' || ca.Status__c == 'Ready for Cancellation'){
            	ca.Has_Approval_Process__c=true;
            } 
        }
        
    }
    
     public void postInsert(List<CooP_Campaign_Activity__c> campaignActivities){
         coopStatsRollUpLogic.campaignRollup(campaignActivities,null);
         /*List<Id> campaignIdList = new List<Id>();
         for(CooP_Campaign_Activity__c ca : campaignActivities){
             campaignIdList.add(ca.Campaign__c);
         }
         if(!isExecutedCampaignRoolup && campaignIdList.size() > 0){
             isExecutedCampaignRoolup = true;
             coopStatsRollUpLogic.campaignRollup(campaignIdList);
         }*/
        
    }
    
      public void postDelete(List<CooP_Campaign_Activity__c> campaignActivities){
      
        coopStatsRollUpLogic.campaignRollup(campaignActivities,null); 
     }
    
      public void postUndelete(List<CooP_Campaign_Activity__c> campaignActivities){
       coopStatsRollUpLogic.campaignRollup(campaignActivities,null);
        
    }
    
}