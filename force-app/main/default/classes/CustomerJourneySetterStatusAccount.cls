//SPRINT 6 JP CXPD-226
//
public class CustomerJourneySetterStatusAccount {
    
    public List<Account> findLapsedCustomerAccount(List<Account> newAccount, Map<Id,Account> oldmap){
      System.debug('findLapsed Customer Account');
        for(Account acc : newAccount){
           Account oldAccount = oldMap.get(acc.id);
               // System.debug('Old Account '+oldAccount);
            if((acc.ntt_Jaguar_Status__c == 'Lapsed Customer' && (oldAccount.ntt_Jaguar_Status__c != 'Lapsed Customer' || oldAccount.ntt_Jaguar_Status__c == null))||(acc.ntt_Land_Rover_Status__c == 'Lapsed Customer' && (oldAccount.ntt_Land_Rover_Status__c != 'Lapsed Customer' || oldAccount.ntt_Land_Rover_Status__c == null)) ){
              acc.Customer_Journey_Stage__c =  'Lapse'; 
            }
            
        }
        
        return newAccount;
        
    }
       public List<Account> renewEnjoyCustomerAccount(List<Account> newAccount, Map<Id,Account> oldmap){
      System.debug('findLapsed Customer Account');
        for(Account acc : newAccount){
           Account oldAccount = oldMap.get(acc.id);
              //  System.debug('Old Account '+oldAccount);
            if((acc.ntt_Jaguar_Status__c == 'Lapsed Customer' && (oldAccount.ntt_Jaguar_Status__c != 'Lapsed Customer' || oldAccount.ntt_Jaguar_Status__c == null))||(acc.ntt_Land_Rover_Status__c == 'Lapsed Customer' && (oldAccount.ntt_Land_Rover_Status__c != 'Lapsed Customer' || oldAccount.ntt_Land_Rover_Status__c == null)) ){
              acc.Customer_Journey_Stage__c =  'Lapse'; 
            }
            
        }
        
        return newAccount;
        
    }
    
    public void setMaintainFromRoadsideEvent(List<Event> roadsides){
        System.debug('Entered setMaintainFromRoadsideEvent');
        System.debug(roadsides);
        Id retailerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').GetRecordTypeId();
        Set<Id> assetIds = SObjectUtilities.GetFieldValuesId(roadsides, 'WhatId'); 
        System.debug('Asset ID is '+ assetIds);
        Map<Id,Account> accs = new Map<Id, Account>();
        List<Account> accountToBeUpdated = new List<Account>();
        List<Asset> assets = [Select id, AccountId, Account.Customer_Journey_Stage__c  FROM Asset where id in:assetIds];
                System.debug('Asset list is '+ assets);
        for(Asset ass : assets){
            
            if(ass.Account.Customer_Journey_Stage__c == null || ass.Account.Customer_Journey_Stage__c == 'Take the Keys' ||ass.Account.Customer_Journey_Stage__c == 'Enjoy'||ass.Account.Customer_Journey_Stage__c == 'Lapsed' ){
                if(!accs.containsKey(ass.AccountId)){
                    Account acc = new Account();
                    acc.Id = ass.AccountId;
                    acc.Customer_Journey_Stage__c = 'Maintain';
                    accs.put(ass.AccountId, acc); 
                    accountToBeUpdated.add(acc);
                }
            }
        }
        update accountToBeUpdated;
    }
    
    
    
    public  List<Account> getAccountsRelatedToOpp(List<Opportunity> opps){
        Set<Id> accountIDs = SObjectUtilities.GetFieldValuesId(opps, 'AccountId');        
        List<Account> accs = [Select Id,  Customer_Journey_Stage__c,ntt_Jaguar_Status__c from Account where id in :accountIDs];        
        return accs;
    }
    public List<Account> getAccountAtUpdateablePURCHASEStage( List<Account> accs){
        List<Account> updateableAccounts = new List<Account>();
        for(Account acc : accs){
            if(!(acc.Customer_Journey_Stage__c == 'Renew') &&  !(acc.Customer_Journey_Stage__c == 'Resolve')     ){
                updateableAccounts.add(acc);
            }
        }
        
        return updateableAccounts;
        
    }
    public boolean isAccountToBeUpdatedToPURCHASEStage( Account acc){
        boolean shouldUpdate = false;
        
        if(!(acc.Customer_Journey_Stage__c == 'Renew') &&  !(acc.Customer_Journey_Stage__c == 'Resolve')     ){
            shouldUpdate = true;
        }
        
        
        return shouldUpdate;
        
    }
    public boolean isAccountToBeUpdatedToTAKEOWNERSHIPStage( Account acc){
        boolean shouldUpdate = false;
        
        if(!(acc.Customer_Journey_Stage__c == 'Renew') &&  !(acc.Customer_Journey_Stage__c == 'Resolve')  &&  !(acc.Customer_Journey_Stage__c == 'Enjoy')   ){
            shouldUpdate = true;
        }        
        
        return shouldUpdate;        
    }
    
    
    public  void setAccountsRelatedToOppToSELECT(List<Account> accs ){
        List<Account> updateAccs = new List<Account>();
        for(Account acc : accs){
            
            Account add = new Account();
            add.Id = acc.Id;
            add.Customer_Journey_Stage__c = 'Select';
            UpdateAccs.add(add);
        }
        update UpdateAccs;
    }
    
    public List<Account> getAccountsRelatedToRoadsideRecord( List<Event> events){
        Id retailerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').GetRecordTypeId();
        List<Account> accs = new List<Account>();
        Set<Id> AssetId = SObjectUtilities.GetFieldValuesId(events,'WhoId');
        
        List<Asset> assets = [SELECT Id, AccountId, Account.Customer_Journey_Stage__c FROM asset WHERE Account.RecordtypeId !=: retailerId  ];
        for(Asset asset: assets){            
            
        }        
        
        return accs;
    }
  /*  
    public void getAccountsForCRCCaseOpened(List<Case> cases){
          Id crcId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NSC').GetRecordTypeId();
          Id retailerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').GetRecordTypeId();
        List<Case> newCRCCasesWithAccount = new List<Case>();
     
        for(Case ca : cases){
            if(ca.RecordTypeId == crcId && ca.AccountId != null){
                newCRCCasesWithAccount.add(ca);
            }
            
        }
        if(!newCRCCasesWithAccount.isEmpty()){
            Set<Id> accountsId = SObjectUtilities.GetFieldValuesId(newCRCCasesWithAccount, 'AccountId');
            List<Account> accountsToBeUpdated = [SELECT  Id, Customer_Journey_Stage__c FROM  Account WHERE RecordtypeId !=: retailerId and id in :accountsId  and Customer_Journey_Stage__c != 'Renew'];
            for(Account acc : accountsToBeUpdated){
                acc.Customer_Journey_Stage__c = 'Resolve';
                
                
            }
            Update accountsToBeUpdated;
            
        
        
        }       
        
        
        
    }
        public void getAccountsForCRCCaseClosed(List<Case> cases, Map<Id,Case> oldCases){
          Id crcId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NSC').GetRecordTypeId();
          Id retailerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').GetRecordTypeId();
        List<Case> closedCRCCasesWithAccount = new List<Case>();
     
        for(Case ca : cases){
            if(ca.RecordTypeId == crcId && ca.AccountId != null && ca.Status == 'Closed' && ca.ClosedDate != null ){
                Case oldCase = oldCases.get(ca.id);
                if(oldCase.Status != ca.Status || oldCase.ClosedDate != ca.ClosedDate)
                closedCRCCasesWithAccount.add(ca);
            }
            
        }
        if(!closedCRCCasesWithAccount.isEmpty()){
            Set<Id> accountsId = SObjectUtilities.GetFieldValuesId(closedCRCCasesWithAccount, 'AccountId');
            List<Account> accountsToBeUpdated = [SELECT  Id, Customer_Journey_Stage__c FROM  Account WHERE RecordtypeId !=: retailerId and id in :accountsId  and Customer_Journey_Stage__c = 'Resolve'];
            for(Account acc : accountsToBeUpdated){
                acc.Customer_Journey_Stage__c = 'Maintain';
                
                
            }
            Update accountsToBeUpdated;         
        
        
        }       
        
        
        
    }*/
    
    
    
}