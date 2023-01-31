public class AccountRelatedObjectOwnerSetter {
    
	//THIS IS NO LONGER REQUIRED AS OWNER ID IS NOW CORRECT OWNER ID
	
    /*public void ReassignRelatedObjectsToNewOwner(List<Account> oldAccounts, Map<Id, Account> newAccountsMappedToIds)
    {
        List<SObject> masterUpdateList = new List<SObject>();
        //Opportunities
        List<string> opportunityQuery = new List<string>{'SELECT Id, AccountId, Validation_Rule_Owner_Check__c, OwnerId FROM Opportunity WHERE IsClosed = false AND (',
            											'AccountId'};
        //Cases
        List<string> caseQuery = new List<string>{'SELECT Id, AccountId, Validation_Rule_Owner_Check__c, OwnerId FROM Case WHERE IsClosed = false AND (',
            											'AccountId'};
        //Notes
        List<string> noteQuery = new List<string>{'SELECT Id, OwnerId, ParentID FROM Note WHERE ', 
            										'ParentId'};
        //Attachments
        List<string> attachmentQuery = new List<string>{'SELECT Id, OwnerId, ParentID FROM Attachment WHERE ', 
            										'ParentId'};
        //Events
        List<string> eventQuery = new List<string>{'SELECT Id, OwnerId, AccountID FROM Event WHERE EndDateTime > TODAY AND (', 
            										'AccountId'};
        //Tasks
        List<string> taskQuery = new List<string>{'SELECT Id, OwnerId, AccountID FROM Task WHERE IsClosed = false AND (', 
            										'AccountId'};
        List<List<string>> queryStrings = new List<List<string>>{opportunityQuery, caseQuery, noteQuery, attachmentQuery, eventQuery, taskQuery};
        for(List<string> queryString : queryStrings)
        {
            List<SObject> objectsToUpdate = ReassignGenericRelatedObjectsToNewAccountOwner(oldAccounts, newAccountsMappedToIds, queryString[0], queryString[1]);
            masterUpdateList.addAll(objectsToUpdate);
        }
        update masterUpdateList;
    }
    
    public void ReassignContactRelatedObjectsToNewAccountOwner(Map<Id, Account> oldAccounts, Map<Id, Account> newAccountsMappedToIds)
    {
        List<SObject> relatedObjectsToUpdate = new List<SObject>();
        String WhereClauseFormat = '(AccountId = \'\'{0}\'\')';
       	string whereClauseStart = 'SELECT Id, AccountID, Name, (SELECT Id, OwnerId FROM Tasks WHERE IsClosed = false), (Select Id, OwnerId From Events), (Select Id, OwnerId FROM Notes), (Select Id, OwnerId FROM Attachments) FROM Contact WHERE ';
        
        List<Contact> relatedContacts = SObjectUtilities.QueryWithMultipleOrs(whereClauseStart, whereClauseFormat, new List<string>{'Id'}, oldAccounts.values());
        
        for(Contact relatedContact : relatedContacts)
        {
            Account relatedAccount = newAccountsMappedToIds.get(relatedContact.AccountId);
            Account oldAccount = oldAccounts.get(relatedContact.AccountId);            
            List<SObject> eventsToUpdate = UpdateRelatedObjectOwners(relatedContact.Events, oldAccount, relatedAccount);
            List<SObject> tasksToUpdate = UpdateRelatedObjectOwners(relatedContact.Tasks, oldAccount, relatedAccount);
            List<SObject> notesToUpdate = UpdateRelatedObjectOwners(relatedContact.Notes, oldAccount, relatedAccount);
            List<SObject> attachmentsToUpdate = UpdateRelatedObjectOwners(relatedContact.Attachments, oldAccount, relatedAccount);
            
            relatedObjectsToUpdate.addAll(eventsToUpdate);
            relatedObjectsToUpdate.addAll(tasksToUpdate);
            relatedObjectsToUpdate.addAll(notesToUpdate);
            relatedObjectsToUpdate.addAll(attachmentsToUpdate);
            
            update relatedObjectsToUpdate;            
        }
    }
    
    public List<SObject> UpdateRelatedObjectOwners(List<SObject> relatedObjects, Account oldAccount, Account newAccount)
    {
        List<SObject> objectsToBeUpdated = new List<SObject>();
        for(SObject relatedObj : relatedObjects)
        {
            if((Id)relatedObj.get('OwnerId') == oldAccount.Pseudo_Account_Owner__c)
            {
                relatedObj.put('OwnerId', newAccount.Pseudo_Account_Owner__c);
                objectsToBeUpdated.add(relatedObj);
            }
        }
        return objectsToBeUpdated;
    }
        
    public List<SObject> ReassignGenericRelatedObjectsToNewAccountOwner(List<Account> oldAccounts, Map<Id, Account> newAccountsMappedToIds, string startQuery, string accountFieldName)
    {
        AccountAndContactOwnerAndShare_Setter shareSetter = new AccountAndContactOwnerAndShare_Setter();
        List<SObject> objectsToUpdate = new List<SObject>();
        //List<Account> accountsWithPseudoOwners = shareSetter.GetAccountsWithPseudoOwners(oldAccounts);
        String WhereClauseFormat = '(' + accountFieldName + ' = \'\'{0}\'\' AND OwnerId = \'\'{1}\'\')';
        //List<SObject> objectsToBeUpdated = SObjectUtilities.QueryWithMultipleOrs(startQuery, whereClauseFormat, new List<string>{'Id', 'Pseudo_Account_Owner__c'}, accountsWithPseudoOwners);
        List<SObject> objectsToBeUpdated = SObjectUtilities.QueryWithMultipleOrs(startQuery, whereClauseFormat, new List<string>{'Id', 'Pseudo_Account_Owner__c'}, oldAccounts);
        system.debug('objs to be updated ' + objectsToBeUpdated);
        for(SObject toUpdate : objectsToBeUpdated)
        {
            Id accountId = (Id)toUpdate.get(accountFieldName);
            Account newAccount = newAccountsMappedToIds.get(accountId);
            toUpdate.put('OwnerId', newAccount.Pseudo_Account_Owner__c);
            if(toUpdate.getSObjectType() == schema.Case.getSobjectType() || toUpdate.getSObjectType() == schema.Opportunity.getSobjectType())
            {
                Boolean validationRuleCheck = (Boolean)toUpdate.get('Validation_Rule_Owner_Check__c');
                system.debug('val rule check ' + validationRuleCheck);
                toUpdate.put('Validation_Rule_Owner_Check__c', !validationRuleCheck);
            }
            objectsToUpdate.add(toUpdate);
        }
        return objectsToUpdate;
    }*/
    
}