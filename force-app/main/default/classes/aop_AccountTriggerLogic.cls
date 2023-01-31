public without sharing class aop_AccountTriggerLogic {

    public static Map<Id, User> usersMap = new Map<Id, User>(); // Added by NTT as part of Code optimisation - 14/06/2021
    
    public void SetUserToMatchPersonAccountIfHasAOPAccess(List<Account> accounts)
	{
        Set<String> contactIds = SObjectUtilities.GetFieldValues(accounts, Schema.Account.PersonContactId.getDescribe().getName());
        
        Map<Id, User> usersByContactId = new Map<Id, User>();
		// Start - Added by NTT as part of Code optimisation - 14/06/2021
        Boolean runUserQuery = false;
        for (String contactId : contactIds) {
            if (!usersMap.containsKey(contactId)) {
                runUserQuery = true;
            }
        }
        
        if (runUserQuery) {
            for(User user : [SELECT ContactId, aop_Has_AoP_Community_Access__c FROM User WHERE ContactId IN: contactIds]) {
                usersMap.put(user.ContactId, user);
            }
        }
        
        for (String contactId : contactIds) {
            if (usersMap.containsKey(contactId)) {
                usersByContactId.put(contactId, usersMap.get(contactId));
            }
        }
        // End - Added by NTT as part of Code optimisation - 14/06/2021
        
        List<User> usersForUpdate = new List<User>();
        for(Account account : accounts)
        {
            User user = usersByContactId.get(account.PersonContactId);
            if(!account.IsPersonAccount || user == null || !user.aop_Has_AoP_Community_Access__c) { continue; }
                
            user.firstName = account.firstName;
            user.lastName = account.lastName;
            user.email = account.personemail;
            usersForUpdate.add(user);
       }
       if(usersForUpdate.Size() == 0) { return; }
       update usersForUpdate;
   }
}