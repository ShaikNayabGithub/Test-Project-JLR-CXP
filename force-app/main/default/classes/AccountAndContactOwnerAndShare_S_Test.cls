@isTest
public class AccountAndContactOwnerAndShare_S_Test {
    
    /*static testMethod void GetAccountsWhereOwnerHasChanged_Returns1Of2Accounts_WhenOneAccountHasOwnerUpdated()
    {
        //Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        Id corporateRecordType = AccountUtilities.RecordTypes.get('Corporate').Id;
        Account account1 = new Account(Name = 'Account1', RecordTypeId = corporateRecordType);
        Account account2 = new Account(Name = 'Account2', RecordTypeId = corporateRecordType);
        List<Account> oldAccounts =  new List<Account>{account1, account2};
        insert oldAccounts;
        Account newAccount1 = new Account(Id = account1.Id, Pseudo_Account_Owner__c = userInfo.getUserId());
        Account newAccount2 = new Account(Id = account2.Id, Pseudo_Account_Owner__c = account2.Pseudo_Account_Owner__c);
        List<Account> newAccounts = new List<Account>{newAccount1, newAccount2};
            system.debug(newAccounts);
        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(account1.Id, account1);
        oldMap.put(account2.Id, account2);
        system.debug(oldMap);
        
        AccountAndContactOwnerAndShare_Setter shareSetter = new AccountAndContactOwnerAndShare_Setter();
        Map<string, Map<Id, Account>> result = shareSetter.GetAccountsWhereOwnerHasChanged(newAccounts, oldMap);
        system.debug(result);
        
        Map<Id,Account> changedMap = result.get('new');
        system.assertEquals(1, changedMap.size());
    }
    
    static testMethod void GetAccountsWhereOwnerHasChanged_Returns2Of2Accounts_WhenBothOwnersUpdated()
    {   
        //Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        Id corporateRecordType = AccountUtilities.RecordTypes.get('Corporate').Id;
        Account account1 = new Account(Name = 'Account1', RecordTypeId = corporateRecordType);
        Account account2 = new Account(Name = 'Account2', RecordTypeId = corporateRecordType);
        List<Account> oldAccounts =  new List<Account>{account1, account2};
        insert oldAccounts;
        Account newAccount1 = new Account(Id = account1.Id, Pseudo_Account_Owner__c = userInfo.getUserId());
        Account newAccount2 = new Account(Id = account2.Id, Pseudo_Account_Owner__c = userInfo.getUserId());
        List<Account> newAccounts = new List<Account>{newAccount1, newAccount2};
            system.debug(newAccounts);
        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(account1.Id, account1);
        oldMap.put(account2.Id, account2);
        system.debug(oldMap);
        
        AccountAndContactOwnerAndShare_Setter shareSetter = new AccountAndContactOwnerAndShare_Setter();
        Map<string, Map<Id, Account>> result = shareSetter.GetAccountsWhereOwnerHasChanged(newAccounts, oldMap);
        system.debug(result);
        
        Map<Id,Account> changedMap = result.get('new');
        system.assertEquals(2, changedMap.size());
    }
    
    static testMethod void GetExistingShares_ReturnsListSizeOne_GivenAccountSharedOnceToOldOwner()
    {
    	User testUser = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    	System.RunAs(testUser){
	        //Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
	        Id corporateRecordType = AccountUtilities.RecordTypes.get('Corporate').Id;
	        Account account1 = new Account(Name = 'Account1', RecordTypeId = corporateRecordType);
	        insert account1;
	        account1.Pseudo_Account_Owner__c = userInfo.getUserId();
	        
	        AccountAndContactOwnerAndShare_Setter shareSetter = new AccountAndContactOwnerAndShare_Setter();
	        List<AccountShare> result = shareSetter.GetExistingShares(new List<Account>{account1});
	        
	        system.assertEquals(1, result.size());
    	}
    }
    
    static testMethod void GetExistingShares_ReturnsListSizeZero_GivenAccountSharedOnceToOldOwnerThatExistsInObjectShareRecord()
    {
        //Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        Id corporateRecordType = AccountUtilities.RecordTypes.get('Corporate').Id;
        Account account1 = new Account(Name = 'Account1', RecordTypeId = corporateRecordType);
        insert account1;
        //account1.Pseudo_Account_Owner__c = userInfo.getUserId();
        account1 = [SELECT Id, OwnerId, Pseudo_Account_Owner__c FROM Account WHERE Id = :account1.Id];
        
        List<AccountShare> shareList = [SELECT Id FROM AccountShare WHERE AccountId =: account1.Id AND UserOrGroupId = :account1.Pseudo_Account_Owner__c];
        
        ObjectShareRecord__c customerSearchShare = new ObjectShareRecord__c(Name = shareList[0].Id);
        insert customerSearchShare;
        
        AccountAndContactOwnerAndShare_Setter shareSetter = new AccountAndContactOwnerAndShare_Setter();
        List<AccountShare> result = shareSetter.GetExistingShares(new List<Account>{account1});
        
        system.assertEquals(0, result.size());
    }
    
    static testMethod void RemoveSharesToPreviousOwner_DeletesCreatedShare_GivenAccountWithOneShare()
    {
    	User testUser = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    	System.RunAs(testUser){
	        //Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
	        Id corporateRecordType = AccountUtilities.RecordTypes.get('Corporate').Id;
	        Account account1 = new Account(Name = 'Account1', RecordTypeId = corporateRecordType);
	        insert account1;
	        List<AccountShare> initialResult = [SELECT Id FROM AccountShare WHERE AccountId =: account1.Id];
	        account1.Pseudo_Account_Owner__c = userInfo.getUserId();
	        AccountAndContactOwnerAndShare_Setter shareSetter = new AccountAndContactOwnerAndShare_Setter();
	        shareSetter.RemoveSharesToPreviousOwner(new List<Account>{account1});
	        List<AccountShare> result = [SELECT Id FROM AccountShare WHERE AccountId =: account1.Id];
	        
	        system.assertEquals(initialResult.size() -1, result.size());
    	}
    }*/
            

}