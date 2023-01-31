public with sharing class QuickCloneAccountController {
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
     public static Id goldenContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
   //JLR_Contact
    public static Id retailerContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Retailer Contact').getRecordTypeId();
    
      @AuraEnabled
    public static Account getAccount(Id accountId) {
        
        return [SELECT Name, BillingCity, BillingState FROM Account WHERE Id = :accountId];
    }
    @AuraEnabled
    public static Account cloneAccount(Account owner, Id accountId) {
        // Perform isAccessible() and isUpdateable() checks here
        // contact.AccountId = accountId;
        //  upsert contact;
        system.debug('saveContactWithAccount ');
        system.debug('owner '+owner);
        system.debug('accountId '+accountId);
        Account secondaryAccount = new Account();
        User us = [Select id, accountid from User where id = :owner.OwnerId];
        if(us.AccountId != null){
            
            Account acc = [Select id,RecordTypeId, name, firstname, lastname,Primary_Contact__pc,Contacts__pc   from account where id = :accountId];
            if(acc.RecordTypeId == goldenCorporateRecordType || acc.RecordTypeId == goldenIndividualRecordType){
                
                //need to create Primary Accounts for these accounts - there may be more than one Account that links to one Primary Account
                
                ContactSecondaryContactCreator cscc = new ContactSecondaryContactCreator();
                
                secondaryAccount.Is_Primary__c = false;
                secondaryAccount.Owner_Retailer__c = us.accountid;
                secondaryAccount.OwnerId = owner.OwnerId;
                secondaryAccount.Create_Secondary_Account__c = true;
                secondaryAccount.Primary_Account__c = acc.Id;               
                
                if(acc.RecordTypeId == goldenCorporateRecordType){
                    secondaryAccount.Name = acc.Name;
                    secondaryAccount.RecordTypeId = corporateRecordType;
                }
                else if(acc.RecordTypeId == goldenIndividualRecordType ){
                    secondaryAccount.Primary_Account__pc =acc.Id;
                    secondaryAccount.FirstName =    acc.FirstName;
                    secondaryAccount.LastName =    acc.LastName;
                    secondaryAccount.RecordTypeId = individualRecordType;
                }
                
                insert secondaryAccount;
                
                if(acc.RecordTypeId == goldenCorporateRecordType){
                    
                    if(acc.Contacts__pc > 0)
                    {
                        for(Contact con : [SELECT Id,RecordTypeId FROM Contact WHERE AccountId =: acc.Id])
                        {
                        	if(con.recordTypeId == goldenContactRecordType)
                            {                          
                                cscc.createClonedSecondaryContact(con, acc,secondaryAccount);
                            }
                        }
                        
                    }
                }
                else if(acc.RecordTypeId == goldenIndividualRecordType ){
                    if(acc.Primary_Contact__pc != null)
                    {         
                     
                        Contact retrievedContact = [Select Id,RecordTypeId FROM Contact WHERE Id =: acc.Primary_Contact__pc];
                        if(retrievedContact.recordTypeId == goldenContactRecordType)
                        {
                            Contact clonedContact = cscc.createClonedSecondaryContact(retrievedContact, acc,secondaryAccount);
                            secondaryAccount.Primary_Contact__pc = clonedContact.Id;
                        }
                    }
                }
                
                update secondaryAccount;
                
            }else{
                throw new AuraHandledException('Cannot add a secondary account to a secondary.');
            }
        }else{
            throw new AuraHandledException('Incorrect Owner Type, please select retailer owner.');
        }
        
        
        return secondaryAccount;
    }
    
}