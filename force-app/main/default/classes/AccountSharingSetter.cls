public with sharing class AccountSharingSetter {
 static Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();

    
    public static void SetAccountSharingForNewUsers(Set<Id> userIds){
        Set<Id> forShares = new Set<Id>();
        Set<Id> accountIdForShare = new Set<Id>();
        for(User usr : [SELECT Id, Contact.AccountId, Contact.Account.recordTypeId FROM User WHERE Id IN :userIds AND ContactId != null AND Contact.AccountId != null AND Profile.UserLicense.Name = 'Partner Community']){
            forShares.add(usr.Id);
            //CXPD-764 Added by Suhan
            if(usr.Contact.AccountId !=null && retailerRecordTypeId==usr.Contact.Account.recordTypeId)
            accountIdForShare.add(usr.Contact.AccountId);
        }
        if(forShares.size() > 0){
            CreateSharingRules(forShares,accountIdForShare);
        }
    }
    
    @future
    public static void CreateSharingRules(Set<Id> sharingUsers, set<Id> accountIdForShare){
        //if the user has a contact, determine which Account the contact belongs to and enable user to Edit this Account
        List<AccountShare> accountShares = new List<AccountShare>();
        for(User usr : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id IN :sharingUsers]){
            AccountShare acctShr = new AccountShare();
            acctShr.AccountId = usr.Contact.AccountId;
            acctShr.UserOrGroupId = usr.Id;
            acctShr.AccountAccessLevel = 'Edit';
            acctShr.OpportunityAccessLevel = 'None'; //OpportunityAccessLevel is a mandatory field
            accountShares.add(acctShr);
        }
        
        //CXPD-764 Added by Suhan
        if(!accountIdForShare.isEmpty()){
        for(AccountShare shareRec:[select id, AccountAccessLevel from AccountShare where AccountId IN:accountIdForShare AND RowCause='PortalImplicit' AND AccountAccessLevel='Read']){
            shareRec.AccountAccessLevel='Edit';
            accountShares.add(shareRec);
        }
        }
        if(!accountShares.isEmpty()){
            Database.upsert(accountShares, false);
        }
  
    }
    
}