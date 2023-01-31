public class LastSellingRetailerSetter {
  public void Set(List<Opportunity> currentOpportunities, Map<Id,Opportunity> oldOpportunities)
  {
  
    if(currentOpportunities == null || currentOpportunities.isEmpty()){
        return;
    }
    
    List<Opportunity> handoverOpps = new List<Opportunity>();
    for(Opportunity opp : currentOpportunities){
        if(opp.StageName == 'Handover' ) {
            handoverOpps.add(opp);
        }
    }
    
    if(handoverOpps.isEmpty()){
        return;
    }
    
    Id userId = UserInfo.getUserId();
    if(userId == null){
        return;
    }
    List<User> contactUser = [Select Contact.AccountId From User Where Id=:userId AND ContactId != null AND Contact.AccountId != null Limit 1];
    Contact contact;
    if(!contactUser.isEmpty()){
        contact = contactUser[0].Contact;
    }
    if(contact == null){
        return;
    }
    
    List<Account> accountsForUpdate = new List<Account>();
    
    for(Opportunity currentOpp : currentOpportunities)
    {
       Opportunity oldOpp = oldOpportunities.get(currentOpp.id);
        if(currentOpp.IsWon && !oldOpp.IsWon){
              Account account = new Account();
              account.Id = currentOpp.AccountId;
              account.Last_Selling_Retailer__c = contact.AccountId;
              accountsForUpdate.add(account);
        }
    }
        
        update accountsForUpdate;
  }
}