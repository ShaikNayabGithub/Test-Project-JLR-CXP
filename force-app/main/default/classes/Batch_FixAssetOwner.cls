global   class Batch_FixAssetOwner implements Database.batchable<sObject>, Database.Stateful 
{
    string query;
    
    global Batch_FixAssetOwner(String whereFilter) {   
        string au = 'au';
        if(whereFilter != null && whereFilter != ''){
            query='Select id,Driver__c,Lessee__c,name,accountid,Registration_Number__c,Product2.Warranty_Length__c,Product2Id, account.country_iso_code__c, (Select id,Registration_Number__c, name,account__c,Driver__c,Lessee__c, Handover_Date__c  from RDAs__r  order by Handover_Date__c desc limit 1) from asset where account.country_iso_code__c = \'au\' and '+whereFilter;        
        }else{
            query='Select id,Driver__c,Lessee__c,name,accountid,Registration_Number__c,Product2.Warranty_Length__c,Product2Id, account.country_iso_code__c, (Select id,Registration_Number__c, name,account__c,Driver__c,Lessee__c, Handover_Date__c  from RDAs__r  order by Handover_Date__c desc limit 1) from asset where account.country_iso_code__c = \'au\' ';
            
        }
        
        
        
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC )
    { 
        return Database.getQueryLocator(query);
    }  
    
    global void execute(Database.BatchableContext BC, List<Asset> allAusAssets)
    {   
        system.debug('Selected '+json.serializePretty(allAusAssets));
        List<asset> mismatched = new List<Asset>();
        list<role__c> assRoles = new  list<role__c>();
        for(Asset ass :allAusAssets ){
            if(ass.RDAs__r != null && ass.RDAs__r.size() > 0){
                RDA__c rad = ass.RDAs__r[0];
                if(rad.account__c != ass.accountid){
                    Asset arse = new Asset();
                    arse.id = ass.Id;
                    arse.AccountId = rad.Account__c;                    
                    arse.Handover_Date__c = rad.Handover_Date__c; 
                    arse.Lessee__c = rad.Lessee__c;
                    arse.Driver__c =  rad.Driver__c;                  
                    if(rad.Registration_Number__c != null && rad.Registration_Number__c != ''){
                        arse.Registration_Number__c = rad.Registration_Number__c;
                    }                    
                    
                    
                    mismatched.add(arse);                     
                }
            }
            
        }
        if(mismatched.size()>0){
            update mismatched;
        }
        system.debug('mismatched '+mismatched.size());
        system.debug('mismatched here '+json.serializePretty(mismatched));
    }
    
    global void finish(Database.BatchableContext BC) 
    {
    }
    
    
}