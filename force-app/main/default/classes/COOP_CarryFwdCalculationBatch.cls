global class COOP_CarryFwdCalculationBatch implements Database.Batchable<sObject>{
    List<String> ListOfCountryToInclude=system.label.COOP_Contry_To_Include_in_Carryfwd.split(';');
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'select id, Name, Retailer__c,coop_Parent_Brand__c, StartDate, EndDate,'+ 
            'Carry_Forwarded_Budget__c, Carry_Forwarded_Claim_Amount__c from campaign where '+
            'StartDate =THIS_FISCAL_QUARTER AND recordtype.Name=\'Co Op Retailer\' AND '+
            'endDate=THIS_FISCAL_QUARTER AND Market__c IN:ListOfCountryToInclude order by Retailer__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<campaign> newCampaigns) {
        Set<Id> SetOfRetailerId= New Set<Id>();
        Map<String,Campaign> MapRetailerOldCampaign=New Map<String,Campaign>();
        Campaign objOldCamp;
        
        for(campaign newCampaign:newCampaigns)
        {
            SetOfRetailerId.add(newCampaign.Retailer__c);
        }
        
        for(campaign oldCampaign:[select id, 
                                  Retailer__c,
                                  coop_Parent_Brand__c,
                                  Final_Eligible_Budget__c,
                                  Total_Claim_For_Quarter__c
                                  from campaign 
                                  where 
                                  StartDate =LAST_FISCAL_QUARTER AND 
                                  recordtype.Name='Co Op Retailer' AND 
                                  EndDate=LAST_FISCAL_QUARTER AND 
                                  Retailer__c IN:SetOfRetailerId AND
                                  Market__c IN:ListOfCountryToInclude order by Retailer__c])
        {
            MapRetailerOldCampaign.put(oldCampaign.Retailer__c+oldCampaign.coop_Parent_Brand__c, oldCampaign);
        }
        
        if(!MapRetailerOldCampaign.isEmpty())
        {
            for(campaign newCampaign:newCampaigns)
            {
                newCampaign.Carry_Forwarded_Budget__c=0;
                newCampaign.Carry_Forwarded_Claim_Amount__c=0;
                if(MapRetailerOldCampaign.containsKey(newCampaign.Retailer__c+newCampaign.coop_Parent_Brand__c))
                {
                    objOldCamp=MapRetailerOldCampaign.get(newCampaign.Retailer__c+newCampaign.coop_Parent_Brand__c);
                    if(objOldCamp.Final_Eligible_Budget__c>objOldCamp.Total_Claim_For_Quarter__c )
                        newCampaign.Carry_Forwarded_Budget__c=objOldCamp.Final_Eligible_Budget__c-objOldCamp.Total_Claim_For_Quarter__c;
                    else if(objOldCamp.Final_Eligible_Budget__c<objOldCamp.Total_Claim_For_Quarter__c)
                        newCampaign.Carry_Forwarded_Claim_Amount__c=objOldCamp.Total_Claim_For_Quarter__c-objOldCamp.Final_Eligible_Budget__c;
                }
            }
            
            update newCampaigns;
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}