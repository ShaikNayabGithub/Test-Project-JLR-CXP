public class Opportunity_AccountJLRStatusSetter {
    
    
    
    public void SetJLRStatuses(List<Opportunity> opportunities)
    {
        System.debug('SetJLRStatuses');
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        Map<Id, Account> allAccounts = new Map<Id, Account>(); 
        CustomerJourneySetterStatusAccount cjssa = new CustomerJourneySetterStatusAccount();
        List<Account> accs = cjssa.getAccountsRelatedToOpp(opportunities);
        System.debug('LIST returned accounts'+accs.size());
        for(Account acc : accs)
        {
            allAccounts.put(acc.Id, acc);
        }
        for(Opportunity opp : opportunities)
        {
            system.debug('Opp is order '+ opp.StageName);
            if((opp.StageName == 'Order' || opp.StageName == 'Order Taken') && opp.AccountId != null){
                Account account = allAccounts.get(opp.AccountId);
                if( account != null && cjssa.isAccountToBeUpdatedToPURCHASEStage(account)){
                    account.Customer_Journey_Stage__c = 'Commit';
                    accountsToUpdate.put(account.Id, account);
                    system.debug('Added to updated');
                }
            }
            
             if((opp.StageName == 'Handover' || opp.StageName == 'Handover & RDA') && opp.AccountId != null ){
                          
                Account account = allAccounts.get(opp.AccountId);
              
                if( account != null && cjssa.isAccountToBeUpdatedToTAKEOWNERSHIPStage(account)){
                    account.Customer_Journey_Stage__c = 'Take the Keys';
                    accountsToUpdate.put(account.Id, account);
                    system.debug('Added to updated');
                }
            }            
            
        }
        
        
        List<OpportunityLineItem> opportunityLineItems = [SELECT Opportunity.StageName, Opportunity.AccountId, 
                                                          Brand__r.Name FROM OpportunityLineItem WHERE OpportunityId IN: opportunities];
        System.debug('Opportunity Line Items '+opportunityLineItems); 
        for(OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            if(opportunityLineItem.Opportunity.StageName != 'Handover' || 
               opportunityLineItem.Brand__r == null) continue;
            
            Account account = accountsToUpdate.get(opportunityLineItem.Opportunity.AccountId);
            if(account == null) {
                account = new Account(Id = opportunityLineItem.Opportunity.AccountId);
                accountsToUpdate.put(account.Id, account);
            }
            
            
            if(opportunityLineItem.Brand__r.Name == 'Jaguar') {             
                //account.ntt_Jaguar_Status__c = 'Customer';               
                
            } else if(opportunityLineItem.Brand__r.Name == 'Land Rover') {
                
                //account.ntt_Land_Rover_Status__c = 'Customer';
                
                
            }
        }
        
        if(accountsToUpdate.Size() == 0) return;
        update accountsToUpdate.Values();
    }
    
    public void SetJLRStatuses(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunityMap)
    {
        List<Opportunity> opportunitiesWithNewStatus = new List<Opportunity>();
         List<Opportunity> opportunitiesWithEnjoy = new List<Opportunity>();
          List<Account> accsUpdate = new List<Account>();
        for(Opportunity opportunity : opportunities)
        {
            Opportunity oldOpportunity = oldOpportunityMap.get(opportunity.Id);
            if(opportunity.StageName != oldOpportunity.StageName) {
                opportunitiesWithNewStatus.add(opportunity); //Jp changed from old to new
            }
            if(opportunity.Customer_Journey_Stage_Update__c == 'Enjoy' && oldOpportunity.Customer_Journey_Stage_Update__c != 'Enjoy'){
                opportunitiesWithEnjoy.add(opportunity);
            }
        }
        
        if(!opportunitiesWithEnjoy.isEmpty()){
        CustomerJourneySetterStatusAccount cjssa = new CustomerJourneySetterStatusAccount();
        List<Account> accs = cjssa.getAccountsRelatedToOpp(opportunitiesWithEnjoy);
            for(Account acc : accs){
                if(acc.Customer_Journey_Stage__c != null && acc.Customer_Journey_Stage__c == 'Take the Keys' ){
                    acc.Customer_Journey_Stage__c = 'Enjoy';
                   accsUpdate.add(acc);
                    
                }
                if(!accsUpdate.isEmpty()){
                    update accsUpdate;
                }
            }
        }
        
        
        if(opportunitiesWithNewStatus.Size() == 0) return;
        this.SetJLRStatuses(opportunitiesWithNewStatus);
    }
}