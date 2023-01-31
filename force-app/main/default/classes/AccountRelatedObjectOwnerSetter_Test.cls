@isTest
public class AccountRelatedObjectOwnerSetter_Test {
    
    /*@testSetup static void InsertTestUsers()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'JLR System Administrator'];
        User newUser = new User(Username = 'xyzabc@bcd.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US');
		insert newUser;
        User newUser2 = new User(Username = 'xyzabc2@bcd.com', LastName = 'abc', Email = 'a2@b.com', Alias = 'barry', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza2', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US');
		insert newUser2;
    }
    
    static testMethod void UpdateRelatedObjectOwners_SetsOwnerOfOppPassedIn_ToOwnerOfNewAccountPassedIn()
    {
        Opportunity newOpp = new Opportunity(Name = 'newopp', OwnerId = null);
        Account newAccount = new Account(Pseudo_Account_Owner__C = userInfo.getUserId());
        Account oldAccount = new Account(Name = 'oldacc');
        
        AccountRelatedObjectOwnerSetter ownerSetter = new AccountRelatedObjectOwnerSetter();
        List<Opportunity> returnedOps = ownerSetter.UpdateRelatedObjectOwners(new List<Opportunity>{newOpp}, oldAccount, newAccount);
        
        Opportunity result = returnedOps[0];
        system.assertEquals(userInfo.getUserId(), result.OwnerId);
       
    }
    
    static testMethod void UpdateRelatedObjectOwners_SetsOwnerOfSecondOppPassedIn_ToOwnerOfNewAccountPassedIn()
    {
        Opportunity newOpp = new Opportunity(Name = 'newopp', OwnerId = null);
        Opportunity newOpp2 = new Opportunity(Name = 'newopp', OwnerId = null);
        Account newAccount = new Account(Pseudo_Account_Owner__C = userInfo.getUserId());
        Account oldAccount = new Account(Name = 'oldacc');
        
        AccountRelatedObjectOwnerSetter ownerSetter = new AccountRelatedObjectOwnerSetter();
        List<Opportunity> returnedOps = ownerSetter.UpdateRelatedObjectOwners(new List<Opportunity>{newOpp, newOpp2}, oldAccount, newAccount);
        
        Opportunity result = returnedOps[1];
        system.assertEquals(userInfo.getUserId(), result.OwnerId);
       
    }
    
    static testMethod void ReassignGenericRelatedObjectsToNewAccountOwner_ChangesSecondNoteOwnerToNewAccountOwner_GivenCorrectQuery()
    {
        string startQuery = 'SELECT Id, OwnerId, ParentID FROM Note WHERE ';
        string accountFieldName = 'ParentID';
        Account oldAccount = new Account(Name = 'oldacc', Pseudo_Account_Owner__c = userInfo.getUserId());
        insert oldAccount;
        Account newAccount = new Account(Id = oldAccount.Id, Pseudo_Account_Owner__c = null);
        Map<Id, Account> newMap = new Map<Id, Account>();
        newMap.put(oldAccount.id, newAccount);
        Note newNote = new Note(Title = 'testnote', ParentId = oldAccount.Id, OwnerId = userInfo.getUserId());
        Note twoNote = new Note(Title = 'testnote2', ParentId = oldAccount.Id, OwnerId = userInfo.getUserId());
        insert new List<Note>{newNote, twoNote};
        
        AccountRelatedObjectOwnerSetter ownerSetter = new AccountRelatedObjectOwnerSetter();
        List<SObject> resultList = ownerSetter.ReassignGenericRelatedObjectsToNewAccountOwner(new List<Account>{oldAccount}, newMap, startQuery, accountFieldName);
        
        Note result = (Note)resultList[1];
        
        system.assertEquals(null, result.OwnerId);
    }
    
    static testMethod void ReassignContactRelatedObjectsToNewAccountOwner_ReassignsNoteRelatedToContact_ToNewAccountOwner()
    {
        Account oldAccount = new Account(Name = 'oldacc', Pseudo_Account_Owner__c = userInfo.getUserId());
        insert oldAccount;
        Contact newContact = new Contact(LastName = 'McTesterson', AccountId = oldAccount.Id, Email = 'example@example.com');
        insert newContact;
        Note newNote = new Note(Title = 'testnote', ParentId = newContact.Id, OwnerId = userInfo.getUserId());
        insert newNote;
        User newOwner = [SELECT ID FROM User WHERE Username = 'xyzabc@bcd.com' LIMIT 1];
        Account newAccount = new Account(Id = oldAccount.Id, Pseudo_Account_Owner__c = newOwner.Id);
        Map<Id, Account> oldAccs = new Map<Id, Account>();
        oldAccs.put(oldAccount.Id, oldAccount);
        Map<Id, Account> newAccs = new Map<Id, Account>();
        newAccs.put(oldAccount.Id, newAccount);
        
        AccountRelatedObjectOwnerSetter ownerSetter = new AccountRelatedObjectOwnerSetter();
        ownerSetter.ReassignContactRelatedObjectsToNewAccountOwner(oldAccs, newAccs);
        
        Note result = [SELECT OwnerId FROM Note WHERE Id =: newNote.Id];
        
        system.assertEquals(newOwner.Id, result.OwnerId);
    }
    
    static testMethod void ReassignRelatedObjectsToNewOwner_ReassignsTaskToNewAccountOwner_IfOwnedByOldOwner()
    {
        Account oldAccount = new Account(Name = 'oldacc', Pseudo_Account_Owner__c = userInfo.getUserId());
        insert oldAccount;
        Task newTask = new Task(WhatId = oldAccount.Id, Subject =  'testme', OwnerId = userInfo.getUserId());
        insert newTask;
        List<Account> oldAccounts = new List<Account>{oldAccount};
        User newOwner = [SELECT ID FROM User WHERE Username = 'xyzabc@bcd.com' LIMIT 1];
        Account newAccount = new Account(Id = oldAccount.Id, Pseudo_Account_Owner__c = newOwner.Id);
        Map<Id, Account> newAccs = new Map<Id, Account>();
        newAccs.put(oldAccount.Id, newAccount);
        
        AccountRelatedObjectOwnerSetter ownerSetter = new AccountRelatedObjectOwnerSetter();
        ownerSetter.ReassignRelatedObjectsToNewOwner(oldAccounts, newAccs);
        
        Task result = [SELECT OwnerId FROM Task WHERE Id =: newTask.Id];
        system.assertEquals(newOwner.Id, result.OwnerId);
    }
    
    static testMethod void ReassignRelatedObjectsToNewOwner_DoesntReassignTaskToNewAccountOwner_IfNotOwnedByOldOwner()
    {
        User newUser = [SELECT ID FROM User WHERE Username = 'xyzabc@bcd.com' LIMIT 1];
        User newUser2 = [SELECT ID FROM User WHERE Username = 'xyzabc2@bcd.com' LIMIT 1];
        Account oldAccount = new Account(Name = 'oldacc', Pseudo_Account_Owner__c = userInfo.getUserId());
        insert oldAccount;
        Task newTask = new Task(WhatId = oldAccount.Id, Subject =  'testme', OwnerId = newUser2.Id);
        insert newTask;
        List<Account> oldAccounts = new List<Account>{oldAccount};
        Account newAccount = new Account(Id = oldAccount.Id, Pseudo_Account_Owner__c = newUser.Id);
        Map<Id, Account> newAccs = new Map<Id, Account>();
        newAccs.put(oldAccount.Id, newAccount);
        
        AccountRelatedObjectOwnerSetter ownerSetter = new AccountRelatedObjectOwnerSetter();
        ownerSetter.ReassignRelatedObjectsToNewOwner(oldAccounts, newAccs);
        
        Task result = [SELECT OwnerId FROM Task WHERE Id =: newTask.Id];
        system.assertEquals(newUser2.Id, result.OwnerId);
    }
    
    static testMethod void ReassignGenericRelatedObjectsToNewAccountOwner_SetsValidationFlagOnCase_GivenLinkedCase()
    {
        User newUser = [SELECT ID FROM User WHERE Username = 'xyzabc@bcd.com' LIMIT 1];
        Id enquiryRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enquiry').getRecordTypeId();
        system.debug('newuser id ' + newUser.Id);
        Account oldAccount = new Account(Name = 'oldacc', Pseudo_Account_Owner__c = userInfo.getUserId());
        insert oldAccount;
        Opportunity newOpp = new Opportunity(AccountId = oldAccount.Id, OwnerId = userInfo.getUserId(), Name = 'newName', CloseDate = Date.today(), StageName = 'Contacted');
        insert newOpp;
        List<Account> oldAccounts = new List<Account>{oldAccount};
        Account newAccount = new Account(Id = oldAccount.Id, Pseudo_Account_Owner__c = newUser.Id);
        Map<Id, Account> newAccs = new Map<Id, Account>();
        newAccs.put(oldAccount.Id, newAccount);
        string startString = 'SELECT Id, AccountId, Validation_Rule_Owner_Check__c, OwnerId FROM Opportunity WHERE IsClosed = false AND (';
        
        AccountRelatedObjectOwnerSetter ownerSetter = new AccountRelatedObjectOwnerSetter();
        List<Opportunity> result = ownerSetter.ReassignGenericRelatedObjectsToNewAccountOwner(oldAccounts, newAccs, startString,'AccountId');
                
        system.assertEquals(true, result[0].Validation_Rule_Owner_Check__c);
    }*/
}