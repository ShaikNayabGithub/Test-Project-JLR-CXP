global class AssetRoleAccountUpdateBatch implements Database.Batchable<sObject>, database.Stateful {
    Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    Asset_Role_Batch_Setup__mdt AsstRoleSetting;
    List<string> accFieldLst= new List<String>();
    List<string> prsnAccFieldLst= new List<String>();
    Map<Id,Id> primarySecAccMap = New Map<Id,Id>();
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        list<Asset_Role_Batch_Setup__mdt> AsstRoleSettingLst =[select Id, MasterLabel, Asset_Roles__c, Retailer_Account_ID__c, Retailer_Owner_ID__c FROM Asset_Role_Batch_Setup__mdt Where Asset_Roles__c !=null limit 1];
        if(AsstRoleSettingLst.isEmpty()) system.abortJob(bc.getJobId());
        else AsstRoleSetting=AsstRoleSettingLst[0];

        list<string> roleList= AsstRoleSetting.Asset_Roles__c.split(';');
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        for (String fieldName: schemaFieldMap.keySet()) {
            prsnAccFieldLst.add(fieldName);
            if(!fieldName.endsWithIgnoreCase('__pc')) accFieldLst.add(fieldName);
        }    
        // collect the batches of records or objects to be passed to execute
        String query =  'Select Id, Account__c, Primary_Account__c, Account__r.IsPersonAccount FROM Role__c WHERE Account__r.Is_Primary__c=True AND Account__r.Country_ISO_Code__c =\''+AsstRoleSetting.MasterLabel+'\' AND Role__c IN:roleList  order by createddate Desc';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Role__c> assetRoles) {
        Set<Id> assetAccSet = New Set<Id>();
        Set<Id> assetPrsnAccSet = New Set<Id>();
        List<Account> secAccForInsertLst = New List<Account>();
        for(Role__c role :assetRoles)
        {
            if(!primarySecAccMap.containsKey(role.Account__c))
            {
                if(role.Account__r.IsPersonAccount) assetPrsnAccSet.add(role.Account__c);
                else assetAccSet.add(role.Account__c);
            }
        }
        
        //Check for Existing secondary Accounts owned by AU dummy retailer Owner.
        for(Account acc:[select Id, Primary_Account__c from Account where (Primary_Account__c IN:assetPrsnAccSet OR Primary_Account__c IN:assetAccSet) AND ownerId=:AsstRoleSetting.Retailer_Owner_ID__c ])
        {
           primarySecAccMap.put(acc.Primary_Account__c, acc.Id);
           if(assetPrsnAccSet.contains(acc.Primary_Account__c)) assetPrsnAccSet.remove(acc.Primary_Account__c);
           if(assetAccSet.contains(acc.Primary_Account__c)) assetAccSet.remove(acc.Primary_Account__c);
        }
        
        // Creating Corporate Secondery Accounts
        if(!assetAccSet.isEmpty())
        {
            for(Account acc:database.query('select '+string.join(accFieldLst, ', ')+' ,(Select Id from Retailer_Accounts__r Limit 2) From Account Where ID In:assetAccSet'))
            {
                if(acc.Retailer_Accounts__r.size() !=1)
                {
                    account accCloned=acc.clone(false, true, false, false);
                    accCloned.Is_Primary__c=false;
                    accCloned.Primary_Account__c=acc.Id;
                    accCloned.OwnerId=AsstRoleSetting.Retailer_Owner_ID__c;
                    accCloned.Owner_Retailer__c=AsstRoleSetting.Retailer_Account_ID__c;
                    accCloned.Country_ISO_Code__c=AsstRoleSetting.MasterLabel;
                    accCloned.RecordTypeId=CorporateId;
                    accCloned.Corporate_Code__c=null;
                    accCloned.DMS_Identifier__c=null;
                    accCloned.Local_Market_ID__c=null;
                    accCloned.Primary_Dealer_Code__c=null;
                    accCloned.Secondary_Dealer_Code__c=null;
                    secAccForInsertLst.add(accCloned);	
                } else
                    primarySecAccMap.Put(acc.Id,acc.Retailer_Accounts__r[0].Id);
            }
        }
        
        // Creating Individual Secondery Accounts
        if(!assetPrsnAccSet.isEmpty())
        {
            for(Account prsnAcc:database.query('select '+string.join(prsnAccFieldLst, ', ')+' ,(Select Id from Retailer_Accounts__r Limit 2) From Account Where ID In:assetPrsnAccSet'))
            {
                if(prsnAcc.Retailer_Accounts__r.size() !=1)
                {
                    account accCloned=prsnAcc.clone(false, true, false, false);
                    accCloned.Is_Primary__c=false;
                    accCloned.Primary_Account__c=prsnAcc.Id;
                    accCloned.OwnerId=AsstRoleSetting.Retailer_Owner_ID__c;
                    accCloned.Owner_Retailer__c=AsstRoleSetting.Retailer_Account_ID__c;
                    accCloned.Country_ISO_Code__c=AsstRoleSetting.MasterLabel;
                    accCloned.RecordTypeId=individualId;
                    accCloned.DMS_Identifier__pc=null;
                    secAccForInsertLst.add(accCloned);	
                }
                else
                    primarySecAccMap.Put(prsnAcc.Id,prsnAcc.Retailer_Accounts__r[0].Id);
            }
        }
        
        if(!secAccForInsertLst.isEmpty())
        {
			database.insert(secAccForInsertLst, false);
            
            for(Account acc:secAccForInsertLst) primarySecAccMap.put(acc.Primary_Account__c,acc.Id);
            
        }
        
        for(Role__c role :assetRoles)
        {
            role.Primary_Account__c=role.Account__c;
            if(primarySecAccMap.containsKey(role.Account__c)) role.Account__c=primarySecAccMap.get(role.Account__c);
        }
        
        if(!assetRoles.isEmpty()) database.update(assetRoles,false);
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}