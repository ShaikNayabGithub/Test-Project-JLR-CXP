public class coopStatsRollUpLogic {
    
    public static Boolean isupdateCooPLogicRun = false;
    public static Boolean isupdateCooPActivityLogicRun = false;
    public void updateCooPParentsStatFields(List<Campaign> campaigns){
        if(isupdateCooPLogicRun) return;
        //get list of campaign activities   
        List<CooP_Campaign_Activity__c> activities = [Select id, name, Campaign__c from CooP_Campaign_Activity__c where CXP_Campaign__c in:campaigns and CXP_Campaign__c != null and CXP_Campaign__c != '' ];
        System.debug('THE Activitiies'+activities);        
        if(!activities.isEmpty()){
            Set<ID> parents = SObjectUtilities.GetFieldValuesId(activities, 'Campaign__c');
            System.debug('THE SET'+parents);
            List<CooP_Campaign_Activity__c> allActivites = [Select id, name, Campaign__c, CXP_Campaign_Leads__c, CXP_Campaign_Opportunities__c, CXP_Campaign_Won_Opportunites__c ,Number_of_Leads__c,Number_of_Opportunities__c, Number_of_Won_Opportunities__c from CooP_Campaign_Activity__c where Campaign__c in:parents ];
            //loop through getting unique campaign as key
            //map
            Map<Id, List<CooP_Campaign_Activity__c>> campaignKeyActivites = MapByIdField(allActivites,'Campaign__c' );
            system.debug('THE MAP'+campaignKeyActivites);
            List<Campaign> campaignsToUpdate = new List<Campaign>();
            
            for(Id eyeDee : parents){
                List<CooP_Campaign_Activity__c> listtoad = campaignKeyActivites.get(eyeDee);
                system.debug('THE LEngth'+listtoad.size());
                decimal numberOfLeads = 0;
                decimal numberOfOpportunities = 0;
                decimal numberOfWonOpportunity = 0;
                
                for(CooP_Campaign_Activity__c ca : listtoad){
                    System.debug('THE CA '+ ca);
                    if(ca.Number_of_Leads__c != null){
                        numberOfLeads = numberOfLeads + ca.Number_of_Leads__c;
                    }
                    if(ca.CXP_Campaign_Leads__c != null){
                        numberOfLeads = numberOfLeads + ca.CXP_Campaign_Leads__c;
                    }
                    if(ca.CXP_Campaign_Opportunities__c != null){
                        numberOfOpportunities = numberOfOpportunities + ca.CXP_Campaign_Opportunities__c;
                    }
                    if(ca.Number_of_Opportunities__c != null){
                        numberOfOpportunities = numberOfOpportunities + ca.Number_of_Opportunities__c;
                    }
                    if(ca.CXP_Campaign_Won_Opportunites__c != null){
                        numberOfWonOpportunity = numberOfWonOpportunity + ca.CXP_Campaign_Won_Opportunites__c;
                    }
                    if(ca.Number_of_Won_Opportunities__c != null){
                        numberOfWonOpportunity = numberOfWonOpportunity + ca.Number_of_Won_Opportunities__c;
                    }         
                    
                    
                    
                }
                Campaign camp = new Campaign();
                camp.id = eyeDee;
                camp.CoOp_Total_Number_of_Leads__c = numberOfLeads;
                camp.CoOp_Total_Number_of_Opportunities__c = numberOfOpportunities;
                camp.CoOp_Total_Number_of_Won_Opportunities__c = numberOfWonOpportunity;
                campaignsToUpdate.add(camp);
                
            }
            if(campaignsToUpdate.size() > 0) {
                isupdateCooPLogicRun = true; 
                update campaignsToUpdate;
            }
            
        }
        
        
    }
    public void updateCooPParentsStatFieldsFromCampaignActivity(Set<ID> parents){
        if(isupdateCooPActivityLogicRun) return;
        
        
        //  System.debug('THE SET'+parents);
        List<CooP_Campaign_Activity__c> allActivites = [Select id, name, Campaign__c, CXP_Campaign_Leads__c, CXP_Campaign_Opportunities__c, CXP_Campaign_Won_Opportunites__c ,Number_of_Leads__c,Number_of_Opportunities__c, Number_of_Won_Opportunities__c from CooP_Campaign_Activity__c where Campaign__c in:parents ];
        //loop through getting unique campaign as key
        //map
        // System.debug('THE LIST'+allActivites);
        Map<Id, List<CooP_Campaign_Activity__c>> campaignKeyActivites = MapByIdField(allActivites,'Campaign__c' );
        
        List<Campaign> campaignsToUpdate = new List<Campaign>();
        
        for(Id eyeDee : parents){
            List<CooP_Campaign_Activity__c> listtoad = campaignKeyActivites.get(eyeDee);
            
            decimal numberOfLeads = 0;
            decimal numberOfOpportunities = 0;
            decimal numberOfWonOpportunity = 0;
            
            for(CooP_Campaign_Activity__c ca : listtoad){
                System.debug('THE CA '+ ca);
                System.debug('THE CA '+ ca.Number_of_Leads__c);
                if(ca.Number_of_Leads__c != null){
                    numberOfLeads = numberOfLeads + ca.Number_of_Leads__c;
                }
                if(ca.CXP_Campaign_Leads__c != null){
                    numberOfLeads = numberOfLeads + ca.CXP_Campaign_Leads__c;
                }
                if(ca.CXP_Campaign_Opportunities__c != null){
                    numberOfOpportunities = numberOfOpportunities + ca.CXP_Campaign_Opportunities__c;
                }
                if(ca.Number_of_Opportunities__c != null){
                    numberOfOpportunities = numberOfOpportunities + ca.Number_of_Opportunities__c;
                }
                if(ca.CXP_Campaign_Won_Opportunites__c != null){
                    numberOfWonOpportunity = numberOfWonOpportunity + ca.CXP_Campaign_Won_Opportunites__c;
                }
                if(ca.Number_of_Won_Opportunities__c != null){
                    numberOfWonOpportunity = numberOfWonOpportunity + ca.Number_of_Won_Opportunities__c;
                }         
                
                
                
            }
            Campaign camp = new Campaign();
            camp.id = eyeDee;
            camp.CoOp_Total_Number_of_Leads__c = numberOfLeads;          
            camp.CoOp_Total_Number_of_Opportunities__c = numberOfOpportunities;
            camp.CoOp_Total_Number_of_Won_Opportunities__c = numberOfWonOpportunity;
            campaignsToUpdate.add(camp);
            
        }
        if(campaignsToUpdate.size() > 0 ) {
            isupdateCooPActivityLogicRun = true;             
            update campaignsToUpdate;
        }
        
        
    }
    
    public  Map<Id, List<SObject>> MapByIdField(List<SObject> records, string fieldName)    {
        Map<Id, List<SObject>> recordMap = new Map<Id, List<SObject>>();
        
        for(SObject record : records) {
            Id key = (Id)record.get(fieldName);
            List<SObject> subList = recordMap.get(key);
            if(subList == null) {
                subList = new List<SObject>();
                recordMap.put(key, subList);
            }
            
            subList.add(record);
        }
        
        return recordMap;
    }
    
    /*  public static void updateOpportunityCount(Set<ID> campaignActivityIdList){
List<CooP_Campaign_Activity__c> campaignActivityList = new List<CooP_Campaign_Activity__c>();
for(CooP_Campaign_Activity__c ca : [SELECT Id, Number_of_Leads__c, (SELECT Id FROM Leads__r) FROM CooP_Campaign_Activity__c WHERE Id IN :campaignActivityIdList]){
campaignActivityList.add( new CooP_Campaign_Activity__c(Id = ca.Id, Number_of_Leads__c = ca.Leads__r.size()));
}
if(campaignActivityList.size() > 0) update campaignActivityList;
}*/
    public static void updateLeadCount(Set<ID> campaignActivityIdList){
        List<CooP_Campaign_Activity__c> campaignActivityList = new List<CooP_Campaign_Activity__c>();
        if(!campaignActivityIdList.isEmpty()){ // Added by NTT as part of Code optimisation - 14/06/2021
            for(CooP_Campaign_Activity__c ca : [SELECT Id, Number_of_Leads__c, (SELECT Id FROM Leads__r) FROM CooP_Campaign_Activity__c WHERE Id IN :campaignActivityIdList]){
                campaignActivityList.add( new CooP_Campaign_Activity__c(Id = ca.Id, Number_of_Leads__c = ca.Leads__r.size()));
            }
        }
        
        if(campaignActivityList.size() > 0) update campaignActivityList;
    }
    
    public static void campaignRollup(List<ID> campaignIdList){
        List<Campaign> updateCampaignList = new List<Campaign>();
        for(Campaign campaign : [SELECT Id,coop_Actual_spend_per_campaign__c,Planned_spend_to_date_per_campaign__c, (SELECT Id, ActualspendforActivity__c, PlannedspendforActivity__c  FROM Campaign_activities__r) FROM Campaign WHERE Id IN:campaignIdList]){
            Campaign singleCampaign = new Campaign(Id = campaign.Id);
            Decimal actualSpends = 0;
            Decimal plannedSpends = 0;
            for(CooP_Campaign_Activity__c ca : campaign.Campaign_activities__r){
                actualSpends += ca.ActualspendforActivity__c != null ? ca.ActualspendforActivity__c : 0;
                plannedSpends += ca.PlannedspendforActivity__c != null ? ca.PlannedspendforActivity__c : 0 ;
            }
            singleCampaign.coop_Actual_spend_per_campaign__c = actualSpends;
            singleCampaign.Planned_spend_to_date_per_campaign__c = plannedSpends;
            
            updateCampaignList.add(singleCampaign);
        }
        
        
        system.debug(updateCampaignList);
        update updateCampaignList;
        
    }
    
    public static void campaignRollup(List<CooP_Campaign_Activity__c> newList, map<Id,CooP_Campaign_Activity__c> oldMap){
        
        set<id> campignIdSet= new set<id>();
        map<id,Campaign> campaignUpdateMap= new map<id,Campaign>();
        for(CooP_Campaign_Activity__c campActivity:newList)
        {
            if( (oldMap==null || (oldMap!=null && 
               (campActivity.ActualspendforActivity__c !=oldMap.get(campActivity.Id).ActualspendforActivity__c
               || campActivity.PlannedspendforActivity__c !=oldMap.get(campActivity.Id).PlannedspendforActivity__c
                || campActivity.Penalty__c !=oldMap.get(campActivity.Id).Penalty__c
                ||campActivity.Status__c !=oldMap.get(campActivity.Id).Status__c) ))
              )
            {
                campignIdSet.add(campActivity.Campaign__c);
                campaignUpdateMap.put(campActivity.Campaign__c,new campaign(id=campActivity.Campaign__c,coop_Actual_spend_per_campaign__c=0,Planned_spend_to_date_per_campaign__c=0));
            }
        }
        
        
        for(CooP_Campaign_Activity__c campActivity:[SELECT Campaign__c ,
                                                           ActualspendforActivity__c,
                                                           PlannedspendforActivity__c,
                                                           Penalty__c
                                                    FROM CooP_Campaign_Activity__c 
                                                    Where Campaign__c IN :campignIdSet
                                                    AND Status__c Not IN ('Activity Canceled', 'Activity Rejected')])
        {
            
            
            Campaign campObj= new Campaign();
            if(campaignUpdateMap.containsKey(campActivity.Campaign__c)){
                campObj=campaignUpdateMap.get(campActivity.Campaign__c); 
               
                if(campActivity.ActualspendforActivity__c!=null)
                campObj.coop_Actual_spend_per_campaign__c+=campActivity.Penalty__c== null ?campActivity.ActualspendforActivity__c : campActivity.ActualspendforActivity__c - campActivity.Penalty__c;
                if(campActivity.PlannedspendforActivity__c!=null)
                campObj.Planned_spend_to_date_per_campaign__c+= campActivity.PlannedspendforActivity__c;
            }else{
                campObj.Id=campActivity.Campaign__c;
                campObj.coop_Actual_spend_per_campaign__c=0;
                if(campActivity.ActualspendforActivity__c!=null)
                campObj.coop_Actual_spend_per_campaign__c=campActivity.Penalty__c== null ?campActivity.ActualspendforActivity__c : campActivity.ActualspendforActivity__c - campActivity.Penalty__c;
                campObj.Planned_spend_to_date_per_campaign__c=0;
                if(campActivity.PlannedspendforActivity__c!=null)
                campObj.Planned_spend_to_date_per_campaign__c=campActivity.PlannedspendforActivity__c;
            }
            campaignUpdateMap.put(campObj.Id, campObj);
        }
        
        if(!campaignUpdateMap.isEmpty())
            update campaignUpdateMap.values();
    }
    
}