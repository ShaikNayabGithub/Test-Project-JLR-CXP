public without sharing class AccountAndContactOwnerAndShare_Setter {

	//THIS IS NO LONGER REQUIRED AS OWNER ID IS NOW CORRECT OWNER ID

    /*public void CreateAccountShareForPseudoOwner(Map<Id, Account> oldAccountMap, List<Account> newAccounts){
        Id retailerRecordType = AccountUtilities.RecordTypes.get('Retailer').Id;
        List<AccountShare> accountShares = new List<AccountShare>();
        for(Account acc : newAccounts){
            if(acc.Pseudo_Account_Owner__c != null && acc.Pseudo_Account_Owner__c != GenericUser.Id){
                if(oldAccountMap == null || !oldAccountMap.containsKey(acc.Id) || oldAccountMap.get(acc.Id).Pseudo_Account_Owner__c != acc.Pseudo_Account_Owner__c){
                    accountShares.add(new AccountShare(AccountId=acc.Id, UserOrGroupId=acc.Pseudo_Account_Owner__c, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none'));
                }
            }
        }
        insert accountShares;
    }
    
    public void SetAccountOwnerToGeneric(List<Account> newAccounts){
        Id retailerRecordType = AccountUtilities.RecordTypes.get('Retailer').Id;
        Map<Id, Id> currentOwnerMap = new Map<Id, Id>();
        for(Account acc : newAccounts){
            if(acc.RecordTypeId != retailerRecordType){
                if(acc.Pseudo_Account_Owner__c == null){
                    acc.Pseudo_Account_Owner__c = acc.OwnerId;
                }
                if(GenericUser.Id != null){
                    acc.OwnerId = GenericUser.Id;
                }
            }            
        }
    }
    
    public void CreateShareForContactOwner(List<Contact> newContacts){
        Set<String> accountIds = SObjectUtilities.GetFieldValues(newContacts, Schema.Contact.AccountId.getDescribe().getName());
        List<Account> accounts = [SELECT OwnerId FROM Account WHERE Id IN: accountIds];
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
        //create manual share on the respective contact's Account
        List<AccountShare> accountShares = new List<AccountShare>();
        Id employeeRecordType;
        if (UserInfo.getLocale()=='en_GB' || UserInfo.getLocale()=='en_US') { //reduce SOQL queries
            employeeRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee Contact').getRecordTypeId();
        } else {
            List<RecordType> recordTypes =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Employee_Contact' AND SobjectType = 'Contact'];
            employeeRecordType = recordTypes[0].Id;
        }
        for(Contact con : newContacts){
            if(con.RecordTypeId != employeeRecordType && con.AccountId != null && con.OwnerId != accountMap.get(con.AccountId).OwnerId){
                accountShares.add(new AccountShare(AccountId=con.AccountId, UserOrGroupId=con.OwnerId, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none'));
            }
        }
        insert accountShares;
    }

    public void SetContactOwnerToGeneric(List<Contact> newContacts){
        if(GenericUser.Id != null){
            for(Contact con : newContacts){
                con.OwnerId = GenericUser.Id;
            }            
        }
    }

    public Map<string, Map<Id, Account>> GetAccountsWhereOwnerHasChanged(List<Account> newAccounts, Map<Id, Account> oldAccountMap)
    {
        //Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();
        Id retailerRecordType = AccountUtilities.RecordTypes.get('Retailer').Id;
        Map<string, Map<Id,Account>> accountChangeListMap = new Map<string, Map<Id,Account>>();
        Map<Id,Account> newAccountsWhereOwnerHasChanged = new Map<Id,Account>();
        Map<Id,Account> oldAccountsWhereOwnerHasChanged = new Map<Id,Account>();
        for(Account newAccount : newAccounts)
        {
            if(newAccount.RecordTypeId != retailerRecordType){
                Account oldAccount = oldAccountMap.get(newAccount.Id);
                if(oldAccount.Pseudo_Account_Owner__c != newAccount.Pseudo_Account_Owner__c)
                {
                    newAccountsWhereOwnerHasChanged.put(newAccount.Id, newAccount);
                    oldAccountsWhereOwnerHasChanged.put(oldAccount.Id, oldAccount);
                }
                else if(oldAccount.OwnerId != newAccount.OwnerId)
                {
                    if(newAccount.OwnerId != GenericUser.Id)
                    {
                        newAccount.Pseudo_Account_Owner__c = newAccount.OwnerId;
                        newAccount.OwnerId = GenericUser.Id;
                        newAccountsWhereOwnerHasChanged.put(newAccount.Id, newAccount);
                        oldAccountsWhereOwnerHasChanged.put(oldAccount.Id, oldAccount);
                    }
                }
            }
        }
        accountChangeListMap.put('new', newAccountsWhereOwnerHasChanged);
        accountChangeListMap.put('old', oldAccountsWhereOwnerHasChanged);
        return accountChangeListMap;
    }

    public void RemoveSharesToPreviousOwner(List<Account> oldAccounts)
    {
        List<AccountShare> existingShares = GetExistingShares(oldAccounts);
        try{
            delete existingShares;
        }catch(Exception e){}// Do something 
    }

    @testVisible private List<AccountShare> GetExistingShares(List<Account> oldAccounts)
    {
        List<AccountShare> allExistingShares = new List<AccountShare>();
        List<AccountShare> existingShares = new List<AccountShare>();
        //List<Account> accountsWithPseudoOwners = GetAccountsWithPseudoOwners(oldAccounts);

        Map<string, ObjectShareRecord__c> customerSearchShares = ObjectShareRecord__c.getAll();
        string accountShareQuery = 'SELECT Id, UserOrGroupId FROM AccountShare WHERE ';
        String WhereClauseFormat = '(AccountId = \'\'{0}\'\' AND UserOrGroupId = \'\'{1}\'\')';
        //allExistingShares = SObjectUtilities.QueryWithMultipleOrs(accountShareQuery, whereClauseFormat, new List<string>{'Id', 'Pseudo_Account_Owner__c'}, accountsWithPseudoOwners);
        allExistingShares = SObjectUtilities.QueryWithMultipleOrs(accountShareQuery, whereClauseFormat, new List<string>{'Id', 'Pseudo_Account_Owner__c'}, oldAccounts);
        for(AccountShare existingShare : allExistingShares)
        {
            if(!customerSearchShares.containsKey(existingShare.Id) && existingShare.UserOrGroupId != GenericUser.Id)
            {
                existingShares.add(existingShare);
            }
        }
        return existingShares;
    }

    public List<Account> GetAccountsWithPseudoOwners(List<Account> oldAccounts)
    {
        List<Account> accountsWithPseudoOwners = new List<Account>();
        for(Account acc : oldAccounts)
        {
            if(acc.Account_Pseudo_Owner_Id__pc != null)
            {
                accountsWithPseudoOwners.add(acc);
            }
        }
        return accountsWithPseudoOwners;
    }

    public static User SystemUser;
    public static User GenericUser{
        get{
            if(SystemUser == null){
                SystemUser = new User();
                List<User> genericUsers = [SELECT Id FROM User WHERE FirstName = 'System' AND LastName = 'User' LIMIT 1];
                if(genericUsers.size() > 0){
                    SystemUser = genericUsers[0];
                }
            }
            return SystemUser;
        }
        set;
    }*/

}