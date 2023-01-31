/* CreatedBy: J Patman
* Date: 24/01/2020
* Triggered: PreUpdate
* Functionality: Automated Secondary Account creation for Aus Market
* 
Updated: Primary Contact fix 
Date: 08/04/2020
* 
* 
* 
* */

public class OpportunityOwnershipChangeLogic {
    
    public void processOpportunityOwnershipChange(List<Opportunity> newOpps, Map<Id,Opportunity> oldMapId, Set<Id> ownerIds){
        Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualPrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        Id CorporatePrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
         Id retailerContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Retailer_Contact').getRecordTypeId();
        
Contact_Secondary_Account_Creator csac = new Contact_Secondary_Account_Creator();        
        Map<Id,User> mapOfUsers = new Map<Id,User>([SELECT Id, PortalRole, Partner_Manager__c, Market__c, Retailer__c, Retailer_Name__c,Contact.AccountId, UserType, Contact_Queue_ID__c, ContactId FROM User WHERE id IN:ownerIds]);
        Set<id> accountIds = new   Set<Id>();
        Map<Id,Account> mapOfAccounts;
                Map<Id,Contact> mapOfPrimaryContacts = new Map<Id,Contact>();
        List<Account> newAccounts = new List<Account>();
         List<Note> newnotes = new List<Note>();
        Map<Id,Account>  mapOfInsertedAccounts = new   Map<Id,Account> ();
        Map<Id, List<Contact>>  mapOfExistingAccountIdToContact = new Map<Id,List<Contact>>();
     
                Map<Id, Contact>  mapOfExistingContactIdToContact = new Map<Id,Contact>();
        List<Contact> secondaryExistingcontacts = new List<Contact>();
        Map<Id,Account>  mapOfExistingChildAccounts = new   Map<Id,Account> ();
        List<Opportunity> validOpps = new List<Opportunity>();
        Set<Id> PrimaryContactIds = new Set<Id>();
            Set<Id> ToBeCreatedPrimaryContactIds = new Set<Id>();
        For(Opportunity newOpp : newOpps){
            if(oldMapId.containsKey(newOpp.id)){                
                Opportunity oldOpp = oldMapId.get(newOpp.Id);
                User oldUser = mapOfUsers.get(oldOpp.OwnerId);                
                User newUser = mapOfUsers.get(newOpp.OwnerId);
                If(newUser.Market__c != null && newUser.Market__c == 'Australia' && newUser.UserType == 'PowerPartner' && oldUser.UserType != 'PowerPartner'){
                    validOpps.add(newOpp);
                    accountIds.add(newOpp.AccountId);
                    PrimaryContactIds.add(newOpp.Primary_Contact__c);
                }               
                
            }
            
        }
        
        If(accountIds != null && accountIds.Size() > 0){
            mapOfAccounts = new Map<Id,Account>( [SELECT Id,(Select Id, firstName, LastName, email, Recordtypeid from contacts), RecordtypeId,(Select Id,Primary_Account__c,PersonContactId, Owner.Retailer__c, Description from Retailer_Accounts__r), Name, FirstName,LastName,PersonMobilePhone,Description, PersonEmail,Website,BillingPostalCode,Phone,Retailer_Email__c,Country_Iso_Code__c, ispersonaccount  FROM Account WHERE Id IN: accountIds]);
      secondaryExistingcontacts =[SELECT Id, Primary_contact__c,Owner.Retailer__c, AccountId FROM Contact WHERE Primary_Contact__c != null AND RecordtypeId = :retailerContactRecordType AND Primary_Contact__c IN :PrimaryContactIds ];
     
            for(Id accId: mapOfAccounts.keySet() ){
                Account Acc = mapOfAccounts.get(accId);               
          
                
                
                if(  Acc.Retailer_Accounts__r !=  null && Acc.Retailer_Accounts__r.size() > 0){
                    //system.debug('Acc.Retailer_Accounts__r '+Acc.Retailer_Accounts__r);
                    List<Account> childAccounts = Acc.Retailer_Accounts__r;
                    for(Account accChild : childAccounts){                        
                        For(Opportunity newOpp : newOpps){                                   
                            User newUser = mapOfUsers.get(newOpp.OwnerId);
                          //  system.debug('newUser '+newUser);
                              system.debug('accChild.Owner.Retailer__c '+accChild.Owner.Retailer__c);
                              system.debug('newUser.Retailer__c '+newUser.Retailer__c);
                            
                            if(newUser !=  null && newUser.Retailer__c != null && accChild.Owner.Retailer__c != null && accChild.Owner.Retailer__c == newUser.Retailer__c ){
                                 system.debug('Added IN ');
                                system.debug('accChild '+accChild);
                                mapOfExistingChildAccounts.put(Acc.Id, accChild);  
                            }
                            if(secondaryExistingcontacts != null && secondaryExistingcontacts.size() > 0){
                                for(Contact con : secondaryExistingcontacts){
                                    if(newUser !=  null && newUser.Retailer__c != null && con.Owner.Retailer__c != null && con.Owner.Retailer__c == newUser.Retailer__c && 
                                       newOpp.Primary_Contact__c != null && newOpp.Primary_Contact__c != con.Primary_Contact__c  ){
                                        
                                        mapOfPrimaryContacts.put(newOpp.Primary_Contact__c, con);
                                    }
                                }
                            }
                              
                            
                            
                        }
                    }
                }
                
            }
            
            
        }
        
        
        
        
        
        for(Opportunity opp : validOpps){
             Account acc = mapOfAccounts.get(opp.AccountId);

            
            If((acc.RecordTypeId == individualPrimaryId || acc.RecordTypeId == CorporatePrimaryId) && (  mapOfExistingChildAccounts == null || mapOfExistingChildAccounts.isEmpty() || (mapOfExistingChildAccounts != null &&  !mapOfExistingChildAccounts.isEmpty() &&  !mapOfExistingChildAccounts.ContainsKey(opp.AccountId)))){         
                Account toBeInserted = new Account();
                               User us = mapOfUsers.get(opp.OwnerId);
                if(acc.RecordTypeId == individualPrimaryId){
                    toBeInserted.RecordTypeId = individualId;
                    toBeInserted.FirstName = acc.FirstName;
                    toBeInserted.LastName = acc.LastName;                   
                    toBeInserted.Primary_Account__pc = acc.Id;
                    
                }
                if(acc.RecordTypeId == CorporatePrimaryId){
                    toBeInserted.RecordTypeId = CorporateId;
                    toBeInserted.Name = acc.Name;
                    
                    
                }
                toBeInserted.Primary_Account__c = acc.Id;
                toBeInserted.Create_Secondary_Account__c = true;
                toBeInserted.Preferred_Sales_Retailer__c = us.Contact.AccountId;
                toBeInserted.OwnerId = us.id;
                newAccounts.add(toBeInserted);
                if(acc.Description != null){
                         Note np = new Note();
                np.Title = opp.Name;
                np.Body = acc.Description;
                np.ParentId = opp.Id;
                newnotes.add(np);   
                }
                if(opp.Primary_Contact__c != null && !acc.ispersonaccount){ //and not personaccount
                    ToBeCreatedPrimaryContactIds.add(opp.Primary_Contact__c);
                }
        
            }
        }
        if(newAccounts !=  null && newAccounts.size() > 0){
            
            insert newAccounts;
            List<Account> newerAccounts = [Select id,PersonContactId, OwnerId,Primary_Account__c from account where id IN :newAccounts ];
           List<Contact> newContacts =    csac.createClonedSecondaryContact(ToBeCreatedPrimaryContactIds,newerAccounts );
            Map<Id, Contact> oldPrimToNewSec = new Map<Id, Contact>();
            for(Contact con : newContacts){
                oldPrimToNewSec.put(con.Primary_Contact__c, con);
            }
            for(Account acc:newerAccounts){
                mapOfInsertedAccounts.put(acc.Primary_Account__c,acc);
            }
            For(Opportunity newOpp : newOpps){
                Account accp = mapOfInsertedAccounts.get(newOpp.AccountId);
               
                newOpp.AccountId = accp.Id;
                if(accp.PersonContactId != null){
                    newOpp.Primary_Contact__c = accp.PersonContactId;
                }else{
                  newOpp.Primary_Contact__c =   oldPrimToNewSec.get(  newOpp.Primary_Contact__c).id;
                }
                
            }
            
            
        }else{
            
            For(Opportunity opp : newOpps){     
                
                If(mapOfExistingChildAccounts != null &&  !mapOfExistingChildAccounts.isEmpty() &&  mapOfExistingChildAccounts.ContainsKey(opp.AccountId)){
                    system.debug('mapOfExistingChildAccounts.ContainsKey(opp.AccountId) '+mapOfExistingChildAccounts.ContainsKey(opp.AccountId));
                     system.debug('opp.AccountId '+opp.AccountId);
                      system.debug('mapOfExistingChildAccounts '+mapOfExistingChildAccounts);

                  
                    Account child = mapOfExistingChildAccounts.get(opp.AccountId);
                    opp.AccountId = mapOfExistingChildAccounts.get(opp.AccountId).Id;
                  // system.debug('child '+child);
                    if(child.PersonContactId != null){
                        opp.Primary_Contact__c = child.PersonContactId;
                    }else{
                        if( opp.Primary_Contact__c != null && mapOfPrimaryContacts != null && mapOfPrimaryContacts.containsKey(opp.Primary_Contact__c) ){
                            opp.Primary_Contact__c = mapOfPrimaryContacts.get(opp.Primary_Contact__c).id;
                        }else{
                             opp.Primary_Contact__c = null;
                        }
                        
                    }
                    
                    if( child != null &&  child.Description != null){
                        
                 Note np = new Note();                
                np.Title = opp.Name;
                np.Body = child.Description;
                np.ParentId = opp.Id;
                newnotes.add(np);                        
                        
                    }
                    
                 
                }
            }
            
        }
        
        if(newnotes !=  null && newnotes.size() > 0){
            insert newnotes;
        }
        
        
    }
    
}