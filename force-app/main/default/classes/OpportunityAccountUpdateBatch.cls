public class OpportunityAccountUpdateBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id individualGoldenRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        Id corporateGoldenRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        
        return Database.getQueryLocator('select id,accountId,Primary_Account__c from opportunity where opportunity.account.is_Primary__c=true and opportunity.account.country_ISO_code__c =\'AU\' and account.recordtypeid IN (:individualGoldenRecordTypeId,:corporateGoldenRecordTypeId)');
    }
    public void execute(Database.BatchableContext BC, List<Opportunity>  scope){
        
        Id individualRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Id corporateRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualGoldenRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        Id corporateGoldenRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        User dummyUsers = [SELECT Id, Name, UserRole.DeveloperName, Country_ISO_Code__c FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE DeveloperName LIKE '%DUMMY%') AND UserType='Standard' AND IsActive = true AND Country_ISO_Code__c='AU' LIMIT 1];
        List<Id> accountIdList = new List<Id>();
        for( Opportunity opp: scope){
            accountIdList.add(opp.AccountId);
        }
        List<Account> updateAcc = new List<Account>();
        Map<Id,Id> priSecList = new Map<Id,Id>();
        List<Account> primaryAccount = [Select Id,recordtypeid,owner.contactId, (Select id from Retailer_Accounts__r),(select id,AccountId from Retailer_Contacts__r) from Account Where Id IN :accountIdList];
        for(Account acc: primaryAccount){   
            system.debug(acc.Retailer_Contacts__r.size() +'8888'+ acc.Retailer_Accounts__r.size());
            if(acc.Recordtypeid == corporateGoldenRecordTypeId ){
                if(acc.Retailer_Accounts__r.size() == 0)    updateAcc.add(new Account(Id= acc.Id,is_Primary__c=false, recordtypeid = corporateRecordTypeId, Create_Golden_Record__c=true));
                else if(acc.Retailer_Accounts__r.size() == 1)    priSecList.put(acc.Id, acc.Retailer_Accounts__r[0].Id);
                if(acc.Retailer_Accounts__r.size() > 0 && acc.owner.contactId != null) updateAcc.add(new Account(Id=acc.Id, ownerId =dummyUsers.Id));
                
            }
            if(acc.Recordtypeid == individualGoldenRecordTypeId){
                if(acc.Retailer_Contacts__r.size() == 0)    updateAcc.add(new Account(Id= acc.Id,is_Primary__c=false, recordtypeid = individualRecordTypeId, Create_Golden_Record__c=true));
                else if(acc.Retailer_Contacts__r.size() == 1)  priSecList.put(acc.Id, acc.Retailer_Contacts__r[0].AccountId);
                if(acc.Retailer_Contacts__r.size() > 0 &&  acc.owner.contactId != null) updateAcc.add(new Account(Id=acc.Id, ownerId =dummyUsers.Id));
            }
        }
        List<Opportunity> oppupdateList = new List<Opportunity>();
        for( Opportunity opp: scope){
            if(priSecList.containskey(opp.AccountId)){
                opp.AccountId = priSecList.get(opp.AccountId);
                oppupdateList.add(opp);
            }
        }
        system.debug(updateAcc);
        system.debug(oppupdateList);
        if(updateAcc.size()>0) update updateAcc;
        if(oppupdateList.size() > 0) update oppupdateList;
    }
    public void finish(Database.BatchableContext BC){}
}