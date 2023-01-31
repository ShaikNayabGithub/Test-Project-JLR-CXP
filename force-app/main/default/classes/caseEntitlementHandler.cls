public class caseEntitlementHandler {
    
    public void SetEntitlementOnCase(List<Case> caseList)
    {
        List<Entitlement> entitlements = [SELECT Id, Name FROM Entitlement WHERE Name like '%Entitlement'];
        if (Test.isRunningTest()) {
            if (entitlements.isEmpty()) { 
                Account RandomAccount = new Account(Name='Test Entitlement Account') ;
                insert RandomAccount;

                entitlements = new List<Entitlement>();
                entitlements.add(new Entitlement(AccountId=RandomAccount.Id,Name = 'Social Media Entitlement'));
                entitlements.add(new Entitlement(AccountId=RandomAccount.Id,Name = 'High Priority Entitlement'));
                entitlements.add(new Entitlement(AccountId=RandomAccount.Id,Name = 'Medium Priority Entitlement'));
                entitlements.add(new Entitlement(AccountId=RandomAccount.Id,Name = 'Low Priority Entitlement'));
                insert entitlements;
                entitlements = [SELECT Id, Name FROM Entitlement WHERE Name like '%Entitlement'];
            }
        }
            
        Entitlement socialMediaEntitlement, highPriorityEntitlement, mediumPriorityEntitlement, lowPriorityEntitlement;
        for(Entitlement e : entitlements){
            if(e.Name == 'Social Media Entitlement') socialMediaEntitlement = e;
            else if(e.Name == 'High Priority Entitlement') highPriorityEntitlement = e;
            else if(e.Name == 'Medium Priority Entitlement') mediumPriorityEntitlement = e;
            else if(e.Name == 'Low Priority Entitlement') lowPriorityEntitlement = e;
        }
                                                                         
        for (Case c : caseList)
        {
            // if the case is a Social Media Case       
            if (c.Social_Media_Case__c == true && socialMediaEntitlement.Id != null)
            {
                // set the Entitlement lookup on Case to the Social Media Entitlement found above
                c.EntitlementId = socialMediaEntitlement.Id;             
            }
            
            // if the case is High Priority and NOT a Social Media Case
            if (c.Priority == 'High' && c.Social_Media_Case__c == false && highPriorityEntitlement != null)
            {
                // set the Entitlement lookup on Case to the High Priority Entitlement found above
                c.EntitlementId = highPriorityEntitlement.Id;
            }
            
            // if the case is Medium Priority and NOT a Social Media Case
            if (c.Priority == 'Medium' && c.Social_Media_Case__c == false && mediumPriorityEntitlement != null)
            {
                // set the Entitlement lookup on Case to the Medium Priority Entitlement found above
                c.EntitlementId = mediumPriorityEntitlement.Id;
            }
            
            // if the case is Low Priority and NOT a Social Media Case
            if (c.Priority == 'Low' && c.Social_Media_Case__c == false && lowPriorityEntitlement != null)
            {
                // set the Entitlement lookup on Case to the Low Priority Entitlement found above
                c.EntitlementId = lowPriorityEntitlement.Id;
            }
        }
    }    
}