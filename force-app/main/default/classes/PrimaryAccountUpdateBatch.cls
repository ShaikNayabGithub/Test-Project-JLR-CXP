global class PrimaryAccountUpdateBatch  implements Database.Batchable<sObject>{
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();  
        return Database.getQueryLocator('SELECT Id,Owner_Retailer__c,Primary_Account__c,Is_Primary__c,RecordTypeId,Data_Enrichment_Priority_Level__c,PersonMailingStreet,PersonEmail,'+
                                        'Phone, Retailer_Email__c, Data_Enrichment_Priority_Effective_To__c, Country_ISO_Code__c, PersonMobilePhone, BillingStreet, LastName, Name, ' +
                                        'Primary_Account__pc, Website, BillingPostalCode, MENA_Reference2__c FROM Account WHERE is_primary__c != true AND primary_account__c = null '+
                                        'AND Country_ISO_Code__c != null AND (recordtypeId =:individualRecordType OR recordtypeId =:corporateRecordType)');
    }  
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){  
        List<Account> updateAccountList = new List<Account>();        
        Map<String, List<Account>> accountMap = new Map<String, List<Account>>();
        List<Account> primaryAccounts = PrimaryAccountUpserter.getPrimaryAccounts(scope);        
        if(primaryAccounts.size() > 0)    
            accountMap = PrimaryAccountUpserter.createAccountMap(primaryAccounts);
        
        for(Account account : (List<Account>) scope){
            Account updateAccount = new Account(Id=account.Id);
            if(account.Owner_Retailer__c != null && !account.Is_Primary__c && account.Primary_Account__c == null){                
                if(account.RecordTypeId == corporateRecordType && accountMap.containskey(account.Name.toLowerCase())){
                    Id primaryId = PrimaryAccountUpserter.getPrimaryAccountId(account, accountMap, false).Id; 
                     system.debug('primaryId'+primaryId);
                    if(primaryId != null){
                        updateAccount.Primary_Account__c = primaryId; 
                        //if(account.Pseudo_Account_Owner__c != null) updateAccount.OwnerId = account.Pseudo_Account_Owner__c;                         
                        updateAccountList.add(updateAccount);
                    }
                }else if(account.RecordTypeId == individualRecordType && accountMap.containskey(account.LastName.toLowerCase())){
                    Id primaryId = PrimaryAccountUpserter.getPrimaryAccountId(account, accountMap, true).Id; 
                    if(primaryId != null){                       
                        updateAccount.Primary_Account__c = primaryId;
                        updateAccount.Primary_Account__pc = primaryId;
                        //if(account.Pseudo_Account_Owner__c != null)  updateAccount.OwnerId = account.Pseudo_Account_Owner__c;   
                        updateAccountList.add(updateAccount);
                    }
                }
            }
        }
        if(updateAccountList.size() > 0){
             Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.update(updateAccountList, dml);
             //update updateAccountList;
        }
           
    }
    
    global void finish(Database.BatchableContext BC)
    {       
        system.debug('**** Finish');
    }
}